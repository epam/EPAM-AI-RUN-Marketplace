output "account_id" {
  description = "Detected account id"
  value       = data.aws_caller_identity.current.account_id
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

output "kms_main_key_id" {
  description = "KMS Main key id for AI/Run TestMate"
  value       = module.main_key.key_id
}

output "kms_codemie_key_id" {
  description = "KMS Codemie integration key id for AI/Run TestMate"
  value       = module.codemie_key.key_id
}
