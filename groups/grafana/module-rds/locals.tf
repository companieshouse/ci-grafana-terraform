locals {
  resource_prefix                 = "${var.service}-${var.environment}"

  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql", "upgrade"] : ["audit", "error", "general", "slowquery"]
  engine_version                  = "${var.engine_major_version}.${var.engine_minor_version}"
  iops                            = var.allocated_storage < 400 ? "3000" : "12000"
  port                            = var.engine == "postgres" ? 5432 : 3306
  storage_throughput              = var.allocated_storage < 400 ? "125" : "500"

  default_tags = {
    Environment = var.environment
    Service     = var.service
    Team        = var.team
  }
}
