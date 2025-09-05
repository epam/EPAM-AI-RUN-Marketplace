terraform {

  required_version = "= 1.5.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.77.0"
    }
  }

}

provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role_arn
  }
}
