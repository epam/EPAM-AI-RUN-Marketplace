variable "region" {
  description = "The AWS region to deploy the cluster into"
  type        = string
  default     = "eu-central-1"
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform"
  type        = string
  default     = "arn:aws:iam::012345678901:role/EKSDeployerRole"
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources"
  type        = string
  default     = "aice"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default = {
    "SysName"     = "AI/Run"
    "Environment" = "Development"
    "Project"     = "AI/Run"
  }
}

variable "vpc_state_bucket" {
  description = "S3 bucket containing VPC state"
  type        = string
}

variable "vpc_state_key" {
  description = "S3 key path for VPC state (e.g. 'vpc/terraform.tfstate')"
  type        = string
}

variable "backend_lock_dynamodb_table" {
  description = "DynamoDB lock table name"
  type        = string
  default     = "" # Optional if not using locking
}

variable "pg_instance_class" {
  description = "Postgres Instance Class"
  type = string
  default = "db.c6gd.medium"
}