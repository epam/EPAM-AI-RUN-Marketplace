output "region" {
  description = "The AWS region where the resources are deployed"
  value       = var.region
}

output "address" {
  description = ""
  value       = module.db.db_instance_address
}

output "database_name" {
  description = ""
  value       = module.db.db_instance_name
}

output "database_user" {
  description = ""
  value       = module.db.db_instance_username
  sensitive   = true
}

output "database_password" {
  description = ""
  value       = random_password.rds_master_password.result
  sensitive   = true
}
