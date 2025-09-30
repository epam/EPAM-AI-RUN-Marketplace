provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "this" {
  name = var.platform_name
}

data "aws_iam_openid_connect_provider" "this" {
  url = data.aws_eks_cluster.this.identity[0].oidc[0].issuer
}

module "sysworker_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                 = "aitestmate-sysworker-role"
  use_name_prefix      = false
  permissions_boundary = var.iam_permissions_boundary_policy_arn

  oidc_providers = {
    this = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["*:aitestmate-sysworker-sa"]
    }
  }

  policies = {}

  tags = var.tags
}

module "worker_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                 = "aitestmate-worker-role"
  use_name_prefix      = false
  permissions_boundary = var.iam_permissions_boundary_policy_arn

  oidc_providers = {
    this = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["*:aitestmate-worker-sa"]
    }
  }

  policies = {
    AmazonBedrockFullAccess = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  }

  tags = var.tags
}

module "api_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "~> 6.2"

  name                 = "aitestmate-api-role"
  use_name_prefix      = false
  permissions_boundary = var.iam_permissions_boundary_policy_arn

  oidc_providers = {
    this = {
      provider_arn               = data.aws_iam_openid_connect_provider.this.arn
      namespace_service_accounts = ["*:aitestmate-api-sa"]
    }
  }

  policies = {}

  tags = var.tags
}

module "main_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description = "AI Run TestMate Main Key"
  key_usage   = "ENCRYPT_DECRYPT"
  aliases     = ["aitestmate-main-key"]

  enable_key_rotation = false

  key_users = [
    module.sysworker_role.arn,
    module.worker_role.arn,
    module.api_role.arn
  ]

  tags = var.tags
}

module "codemie_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "~> 4.0"

  description              = "AI Run TestMate Codemie Integration Key"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "RSA_2048"
  aliases                  = ["aitestmate-codemie-key"]

  enable_key_rotation = false

  key_users = [
    module.sysworker_role.arn,
    module.worker_role.arn,
    module.api_role.arn
  ]

  tags = var.tags
}
