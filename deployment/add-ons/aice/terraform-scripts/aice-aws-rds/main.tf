locals {
  tags = merge(
    var.tags,
    {
      "user:tag" = var.platform_name
    },
  )
}

data "aws_caller_identity" "current" {}

################################################################################
# RDS Postgres
################################################################################

module "aice_db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "aice-rds"

  engine                   = "postgres"
  engine_version           = "17.6"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres17"
  major_engine_version     = "17.6"
  instance_class           = var.pg_instance_class

  allocated_storage        = 20
  max_allocated_storage    = 30

  db_name                  = "aice_db"
  username                 = "aice_user"
  password                 = random_password.rds_master_password_aice.result
  port                     = 5432

  manage_master_user_password = false

  multi_az                 = false
  db_subnet_group_name     = "${var.platform_name}-db-subnet-group"
  vpc_security_group_ids   = [data.terraform_remote_state.vpc.outputs.codemie_vpc_default_sg_id]

  publicly_accessible      = false

  kms_key_id = data.terraform_remote_state.vpc.outputs.codemie_kms_key_arn

}

resource "random_password" "rds_master_password_aice" {
  length  = 12
  special = false
}