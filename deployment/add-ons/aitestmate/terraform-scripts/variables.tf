variable "region" {
  description = "The AWS region to work with, e.g. eu-central-1"
  type        = string
  default     = "eu-central-1"
}

variable "platform_name" {
  description = "The name of the cluster that is used for tagging resources"
  type        = string
  default     = "codemie"
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

variable "iam_permissions_boundary_policy_arn" {
  description = "ARN for permission boundary to attach to IAM policies"
  type        = string
  default     = ""
}
