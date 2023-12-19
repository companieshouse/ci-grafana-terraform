output "rds_endpoint" {
  value = module.grafana_rds.rds_endpoint
}

output "rds_engine_version" {
  value = module.grafana_rds.rds_engine_version
}
