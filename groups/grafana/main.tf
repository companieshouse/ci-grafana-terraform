terraform {
  required_version = "~> 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.12.0"
    }
  }
  backend "s3" {}
}

module "grafana_rds" {
  source = "./module-rds"

  aws_account                 = var.aws_account
  aws_region                  = var.aws_region
  environment                 = var.environment
  service                     = var.service
  team                        = var.team

  vpc_id                      = data.aws_vpc.vpc.id
  subnet_ids                  = data.aws_subnets.deployment.ids
  ingress_cidrs               = local.ingress_cidrs
  ingress_prefix_list_ids     = local.ingress_prefix_list_ids

  db_name                 = local.rds_db_name
  username                = local.rds_username
  password                = local.rds_password
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = var.rds_backup_window
  deletion_protection     = var.rds_deletion_protection
  engine                  = var.rds_engine
  engine_major_version    = var.rds_engine_major_version
  engine_minor_version    = var.rds_engine_minor_version
  instance_class          = var.rds_instance_class
  maintenance_window      = var.rds_maintenance_window
  allocated_storage       = var.rds_allocated_storage
}
