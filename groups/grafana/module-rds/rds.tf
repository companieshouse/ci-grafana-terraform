resource "aws_db_subnet_group" "rds" {
  name       = "${local.resource_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    local.default_tags,
    {
      Name = "${local.resource_prefix}-subnet-group"
    }
  )
}

resource "aws_db_parameter_group" "rds" {
  name        = "${local.resource_prefix}-${var.engine}-parameter-group"
  family      = "${var.engine}-${var.engine_major_version}"
  description = "Parameter group for ${local.resource_prefix}-${var.engine}"

  tags = merge(
    local.default_tags,
    {
      Name = "${local.resource_prefix}-${var.engine}-parameter-group"
    }
  )
}

resource "aws_db_option_group" "rds" {
  name                     = "${local.resource_prefix}-${var.engine}-option-group"
  option_group_description = "Option group for ${local.resource_prefix}-${var.engine}"
  engine_name              = var.engine
  major_engine_version     = var.engine_major_version

  tags = merge(
    local.default_tags,
    {
      Name = "${local.resource_prefix}-${var.engine}-option-group"
    }
  )
}

resource "aws_db_instance" "rds" {
  allocated_storage               = var.allocated_storage
  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  backup_retention_period         = var.backup_retention_period
  backup_window                   = var.backup_window
  db_name                         = var.db_name
  db_subnet_group_name            = aws_db_subnet_group.rds.name
  deletion_protection             = var.deletion_protection
  enabled_cloudwatch_logs_exports = local.enabled_cloudwatch_logs_exports
  engine                          = var.engine
  engine_version                  = local.engine_version
  final_snapshot_identifier       = "${local.resource_prefix}-${var.engine}-final-deletion-snapshot"
  identifier                      = "${local.resource_prefix}-${var.engine}"
  instance_class                  = var.instance_class
  iops                            = local.iops
  maintenance_window              = var.maintenance_window
  multi_az                        = var.multi_az
  username                        = var.username
  password                        = var.password
  option_group_name               = aws_db_option_group.rds.name
  parameter_group_name            = aws_db_parameter_group.rds.name
  port                            = local.port
  skip_final_snapshot             = var.skip_final_snapshot
  storage_throughput              = local.storage_throughput
  storage_type                    = "gp3"
  vpc_security_group_ids          = [aws_security_group.rds.id]

  tags = merge(
    local.default_tags,
    {
      Name = "${local.resource_prefix}-${var.engine}"
    }
  )
}
