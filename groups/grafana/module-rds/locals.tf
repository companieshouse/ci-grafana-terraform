locals {
  resource_prefix                 = "${var.service}-${var.environment}"

  db_engine_lookup_map            = {
    postgres = {
      default_port = 5432
      storage = {
        threshold_gib = 400,
        small = {
          iops = 3000,
          throughput = 125
        },
        large = {
          iops = 12000,
          throughput = 500
        }
      }
    }
    mysql = {
      default_port = 3306
      storage = {
        threshold_gib = 400
        small = {
          iops = 3000,
          throughput = 125
        },
        large = {
          iops = 12000,
          throughput = 500
        }
      }
    },
    mariadb = {
      default_port = 3306
      storage = {
        threshold_gib = 400
        small = {
          iops = 3000,
          throughput = 125
        },
        large = {
          iops = 12000,
          throughput = 500
        }
      }
    }
  }

  enabled_cloudwatch_logs_exports = var.engine == "postgres" ? ["postgresql", "upgrade"] : ["audit", "error", "general", "slowquery"]
  engine_version                  = "${var.engine_major_version}.${var.engine_minor_version}"
  port                            = var.port == 0 ? local.db_engine_lookup_map[var.engine].default_port : var.port

  iops                            = var.allocated_storage < local.db_engine_lookup_map[var.engine].storage.threshold_gib ? local.db_engine_lookup_map[var.engine].storage.small.iops : local.db_engine_lookup_map[var.engine].storage.large.iops
  storage_throughput              = var.allocated_storage < local.db_engine_lookup_map[var.engine].storage.threshold_gib ? local.db_engine_lookup_map[var.engine].storage.small.throughput : local.db_engine_lookup_map[var.engine].storage.large.throughput

  default_tags = {
    Environment = var.environment
    Service     = var.service
    Team        = var.team
  }
}
