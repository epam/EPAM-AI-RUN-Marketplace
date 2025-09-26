output "account_id" {
  description = "Detected account id"
  value       = data.aws_caller_identity.current
}

output "worker_role_arn" {
  description = "IAM role arn for AI/Run TestMate worker pods"
  value       = module.worker_role.arn
}

output "sysworker_role_arn" {
  description = "IAM role arn for AI/Run TestMate sysworker pod"
  value       = module.sysworker_role.arn
}
output "api_role_arn" {
  description = "IAM role arn for AI/Run TestMate api pods"
  value       = module.api_role.arn
}

# output "deployer_iam_role_arn" {

#   description = "IAM role arn for EKS cluster deployment"
#   value       = aws_iam_role.deployer.arn
# }

# output "deployer_iam_role_name" {
#   description = "IAM role name for EKS cluster deployment"
#   value       = aws_iam_role.deployer.name
# }
