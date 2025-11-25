data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = var.vpc_state_bucket
    key            = var.vpc_state_key
    region         = var.region
    dynamodb_table = var.backend_lock_dynamodb_table
    encrypt        = true
  }
}