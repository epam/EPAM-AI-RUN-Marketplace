output "terraform_states_s3_bucket_name" {
  description = "Amazon S3 bucket name for remote Terraform state storage"
  value       = aws_s3_bucket.terraform_states.id
}

output "terraform_lock_table_dynamodb_id" {
  description = "DynamoDB table id for Terraform locking and consistency checking usage"
  value       = aws_dynamodb_table.terraform_lock_table.id
}
