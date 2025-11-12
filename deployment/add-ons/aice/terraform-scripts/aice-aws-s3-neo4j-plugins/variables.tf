variable "region" {
  description = "The AWS region to deploy the cluster into, e.g. eu-central-1"
  type        = string
  default     = "eu-central-1"
}

variable "role_arn" {
  description = "The AWS IAM role arn to assume for running terraform"
  type        = string
  default     = "arn:aws:iam::012345678901:role/EKSDeployerRole"
}

variable "s3_states_bucket_name" {
  description = "Prefix for S3 bucket name. Since the name should be unique the account number will be added as suffix, e.g. terraform-states-012345678910"
  type        = string
  default     = "aice-neo4j-plugin"
}


variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(any)
  default = {
    "SysName"     = "CodeMie"
    "Environment" = "development"
    "Project"     = "CodeMie"
  }
}
