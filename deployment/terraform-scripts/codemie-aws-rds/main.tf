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
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.platform_name}-db-subnet-group"
  description = "Subnet group for RDS instance"
  subnet_ids  = data.terraform_remote_state.vpc.outputs.codemie_vpc_private_subnets

  tags = local.tags
}

module "db" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "${var.platform_name}-rds"

  engine                   = "postgres"
  engine_version           = "17.4"
  engine_lifecycle_support = "open-source-rds-extended-support-disabled"
  family                   = "postgres17"
  major_engine_version     = "17.4"
  instance_class           = var.pg_instance_class

  allocated_storage        = 20
  max_allocated_storage    = 30

  db_name                  = "codemie"
  username                 = "dbadmin"
  password                 = random_password.rds_master_password.result
  port                     = 5432

  manage_master_user_password = false

  multi_az                 = false
  db_subnet_group_name     = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids   = [data.terraform_remote_state.vpc.outputs.codemie_vpc_default_sg_id]

  publicly_accessible      = false
}

resource "random_password" "rds_master_password" {
  length  = 12
  special = false
}