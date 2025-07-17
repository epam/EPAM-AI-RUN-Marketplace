locals {
  tags = merge(
    var.tags,
    {
      "user:tag" = var.platform_name
    },
  )
  cluster_name = var.platform_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = local.cluster_name
}

################################################################################
# VPC
################################################################################
resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = merge(local.tags, tomap({ "Name" = "codemie-nat" }))
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.14.0"

  name = var.platform_name

  create_vpc = true

  cidr            = var.platform_cidr
  azs             = var.subnet_azs
  private_subnets = var.private_cidrs
  public_subnets  = var.public_cidrs

  map_public_ip_on_launch    = false
  enable_dns_hostnames       = true
  enable_dns_support         = true
  enable_nat_gateway         = true
  single_nat_gateway         = true
  one_nat_gateway_per_az     = false
  manage_default_network_acl = false

  default_security_group_ingress = [
    {
      self = true
    }
  ]
  default_security_group_egress = [
    {
      self        = false
      cidr_blocks = "0.0.0.0/0"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
    }
  ]

  reuse_nat_ips       = true
  external_nat_ip_ids = [aws_eip.nat.id]
  tags                = local.tags
}

################################################################################
# NLB
################################################################################
module "nlb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

  name = "${var.platform_name}-nlb"

  load_balancer_type         = "network"
  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  create_security_group      = false
  security_groups            = compact(concat(tolist([module.vpc.default_security_group_id]), var.security_group_ids))
  enable_deletion_protection = false

  listeners = {
    codemie-nats = {
      port            = 30422
      protocol        = "TLS"
      certificate_arn = module.acm.acm_certificate_arn
      forward = {
        target_group_key = "codemie-nats"
      }
    }
  }

  target_groups = {
    codemie-nats = {
      name                 = "${var.platform_name}-nlb-codemie-nats"
      protocol             = "TCP"
      port                 = 30422
      deregistration_delay = 20
      create_attachment    = false
      target_health_state = {
        enable_unhealthy_connection_termination = false
      }
    }
  }

  tags = local.tags
}

module "record_codemie_nats" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "4.1.0"

  zone_name = var.platform_domain_name
  records = [
    {
      name = "codemie-nats"
      type = "A"
      alias = {
        name    = module.nlb.dns_name
        zone_id = module.nlb.zone_id
      }
    }
  ]
}

################################################################################
# ACM
################################################################################
data "aws_route53_zone" "this" {
  name         = var.platform_domain_name
  private_zone = false
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name = var.platform_domain_name
  zone_id     = data.aws_route53_zone.this.zone_id

  validation_method = "DNS"

  subject_alternative_names = [
    "*.${var.platform_domain_name}",
  ]

  tags = merge(local.tags, tomap({ "Name" = var.platform_name }))
}

################################################################################
# ALB
################################################################################
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "9.12.0"

  name = "${var.platform_name}-ingress-alb"

  vpc_id                     = module.vpc.vpc_id
  subnets                    = module.vpc.public_subnets
  create_security_group      = false
  security_groups            = compact(concat(tolist([module.vpc.default_security_group_id]), var.security_group_ids))
  enable_http2               = false
  enable_deletion_protection = false

  listeners = {
    http-https-redirect = {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = 443
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = var.ssl_policy
      certificate_arn = module.acm.acm_certificate_arn

      forward = {
        target_group_key = "https-instance"
      }
    }
  }

  target_groups = {
    http-instance = {
      name                 = "${var.platform_name}-infra-alb-http"
      port                 = 32080
      protocol             = "HTTP"
      deregistration_delay = 20
      create_attachment    = false

      health_check = {
        matcher = 404
      }
    }
    https-instance = {
      name                 = "${var.platform_name}-infra-alb-https"
      port                 = 32443
      protocol             = "HTTPS"
      deregistration_delay = 20
      create_attachment    = false

      health_check = {
        matcher = 404
      }
    }
  }
  idle_timeout = 500

  tags = local.tags
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "4.1.0"

  zone_name = var.platform_domain_name
  records = [
    {
      name = "*"
      type = "A"
      alias = {
        name    = module.alb.dns_name
        zone_id = module.alb.zone_id
      }
    }
  ]
}
################################################################################
# EKS
################################################################################
module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.0.3"

  key_name              = format("%s-%s", local.cluster_name, "key-pair")
  private_key_algorithm = "ED25519"
  create_private_key    = true

  tags = local.tags
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.26.0"

  enable_cluster_creator_admin_permissions = true
  cluster_name                             = local.cluster_name
  cluster_version                          = var.cluster_version
  cluster_endpoint_public_access           = true

  create_iam_role               = true
  iam_role_use_name_prefix      = false
  iam_role_permissions_boundary = var.role_permissions_boundary_arn

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  create_cloudwatch_log_group                = false
  cluster_enabled_log_types                  = []
  create_node_security_group                 = false
  create_cluster_primary_security_group_tags = false

  create_cluster_security_group = false
  cluster_security_group_id     = module.vpc.default_security_group_id

  cluster_encryption_config = {}

  # Self Managed Node Group(s)
  self_managed_node_group_defaults = {
    subnet_ids                    = [module.vpc.private_subnets[1]] # set [module.vpc.private_subnets[1]] to deploy in eu-central-1b
    post_bootstrap_user_data      = var.add_userdata
    target_group_arns             = [module.alb.target_groups["http-instance"].arn, module.alb.target_groups["https-instance"].arn, module.nlb.target_groups["codemie-nats"].arn]
    key_name                      = module.key_pair.key_pair_name
    enable_monitoring             = false
    use_mixed_instances_policy    = true
    iam_role_use_name_prefix      = false
    iam_role_permissions_boundary = var.role_permissions_boundary_arn
    block_device_mappings = {
      xvda = {
        device_name = "/dev/xvda"
        ebs = {
          volume_size           = 30
          volume_type           = "gp3"
          iops                  = 3000
          throughput            = 150
          encrypted             = false
          delete_on_termination = true
        }
      }
    }

    # IAM role
    create_iam_instance_profile = true
  }

  self_managed_node_groups = {
    worker_group_spot = {
      name = format("%s-%s", local.cluster_name, "spot")

      min_size     = var.spot_min_nodes_count
      max_size     = var.spot_max_nodes_count
      desired_size = var.spot_desired_nodes_count
      ami_type     = var.ami_type

      iam_role_use_name_prefix      = false
      iam_role_permissions_boundary = var.role_permissions_boundary_arn

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=spot'"

      mixed_instances_policy = {
        instances_distribution = {
          spot_instance_pools = 2
        }
        override = var.spot_instance_types
      }

      # Schedulers
      create_schedule = true
      schedules = {
        "Start" = {
          min_size     = var.spot_min_nodes_count
          max_size     = var.spot_max_nodes_count
          desired_size = var.spot_desired_nodes_count
          recurrence   = "00 6 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
        "Stop" = {
          min_size     = 0
          max_size     = 0
          desired_size = 0
          recurrence   = "00 18 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
      }
    },
    worker_group_on_demand = {
      name = format("%s-%s", local.cluster_name, "on-demand")

      min_size     = var.demand_min_nodes_count
      max_size     = var.demand_max_nodes_count
      desired_size = var.demand_desired_nodes_count
      ami_type     = var.ami_type
      iam_role_use_name_prefix      = false
      iam_role_permissions_boundary = var.role_permissions_boundary_arn

      bootstrap_extra_args = "--kubelet-extra-args '--node-labels=node.kubernetes.io/lifecycle=normal'"

      mixed_instances_policy = {
        override = var.demand_instance_types
      }

      # Schedulers
      create_schedule = true
      schedules = {
        "Start" = {
          min_size     = var.demand_min_nodes_count
          max_size     = var.demand_max_nodes_count
          desired_size = var.demand_desired_nodes_count
          recurrence   = "00 6 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
        "Stop" = {
          min_size     = 0
          max_size     = 0
          desired_size = 0
          recurrence   = "00 18 * * MON-FRI"
          time_zone    = "Etc/UTC"
        },
      }
    },
  }

  # OIDC Identity provider
  cluster_identity_providers = var.cluster_identity_providers

  # Addons
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.aws_ebs_csi_driver_irsa.iam_role_arn
    }
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
    }
  }

  access_entries = {
    ai-run-admin = {
      principal_arn = var.eks_admin_role_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = local.tags
}

module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.26.0"

  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = var.aws_auth_roles
  aws_auth_users = var.aws_auth_users
}

module "aws_ebs_csi_driver_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_EBS_CSI_Driver"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_policy_arns = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = local.tags
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_VPC_CNI"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
  tags = local.tags
}

data "aws_caller_identity" "current" {}

module "externalsecrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  role_name                     = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_ExternalSecretOperatorAccess"
  assume_role_condition_test    = "StringLike"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn

  attach_external_secrets_policy = true
  policy_name_prefix             = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}"
  external_secrets_ssm_parameter_arns = [
    "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter/codemie/*"
  ]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*"]
    }
  }
  tags = local.tags
}

################################################################################
# S3 Storage
################################################################################
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  version = "4.11.0"

  create_bucket = var.enable_codemie_s3_file_storage
  bucket        = "${lower(local.cluster_name)}-user-data-${data.aws_caller_identity.current.account_id}"
  acl           = "private"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
  attach_deny_insecure_transport_policy = true
  tags                                  = local.tags
}

################################################################################
# AI/Run IAM Role
################################################################################
data "aws_iam_policy_document" "ai_run_kms_policy" {
  version = "2012-10-17"

  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "ai_run_kms_policy" {
  name   = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_AI_RUN_KMS"
  policy = data.aws_iam_policy_document.ai_run_kms_policy.json

  tags = local.tags
}

data "aws_iam_policy_document" "ai_run_s3_policy" {
  version = "2012-10-17"

  statement {
    sid    = "S3ObjectAccess"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::${module.s3_bucket.s3_bucket_id}/*",
    ]
  }
}

resource "aws_iam_policy" "ai_run_s3_policy" {
  name   = "AWSIRSA_${replace(title(local.cluster_name), "-", "")}_AI_RUN_S3"
  policy = data.aws_iam_policy_document.ai_run_s3_policy.json

  tags = local.tags
}

module "ai_run_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.47.1"

  role_name                     = "AWSIRSA_${replace(upper(local.cluster_name), "-", "")}_AI_RUN"
  assume_role_condition_test    = "StringLike"
  role_permissions_boundary_arn = var.role_permissions_boundary_arn
  role_policy_arns = {
    AIRunKMSPolicy     = aws_iam_policy.ai_run_kms_policy.arn
    AIRunBedrockPolicy = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
    AIRunS3Policy      = aws_iam_policy.ai_run_s3_policy.arn
  }

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["*"]
    }
  }

  tags = local.tags
}

data "aws_iam_policy_document" "ai_run_kms_key_policy" {
  version = "2012-10-17"
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}

module "ai_run_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "3.1.1"

  description                        = "AI Run key usage"
  key_usage                          = "ENCRYPT_DECRYPT"
  enable_key_rotation                = false
  aliases                            = ["airun-${replace(lower(local.cluster_name), "-", "")}"]
  policy                             = data.aws_iam_policy_document.ai_run_kms_key_policy.json
  key_administrators                 = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  bypass_policy_lockout_safety_check = true

  tags = local.tags
}
