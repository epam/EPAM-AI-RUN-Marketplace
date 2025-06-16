terraform {
  required_version = "= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.34.0"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}
