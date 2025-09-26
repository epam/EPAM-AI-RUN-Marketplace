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

  policies = {
    AmazonBedrockFullAccess = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  }
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

  policies = {
    AmazonBedrockFullAccess = "arn:aws:iam::aws:policy/AmazonBedrockFullAccess"
  }
}
