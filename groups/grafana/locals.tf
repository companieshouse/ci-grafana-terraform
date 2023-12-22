locals {
  secrets                 = data.vault_generic_secret.secrets.data

  subnet_pattern          = local.secrets.subnet_pattern
  vpc_pattern             = local.secrets.vpc_pattern
  rds_username            = local.secrets.rds_username
  rds_password            = local.secrets.rds_password
  rds_db_name             = var.service

  resource_prefix         = "${var.service}-${var.environment}"
  ingress_prefix_list_ids = [
    data.aws_ec2_managed_prefix_list.admin.id
  ]
  ingress_cidrs           = [
    for s in data.aws_subnet.deployment : s.cidr_block
  ]
  create_ssl_certificate  = var.ssl_certificate_name == ""

  stack_name              = "platform-services"
  name_prefix             = "${local.stack_name}-${var.environment}"

  lb_listener_rule_priority = 10
  lb_listener_paths         = ["/*"]
  healthcheck_path          = "/api/health"
  healthcheck_matcher       = "200"

  parameter_store_secrets = {
    "gf_database_user"           = local.rds_username
    "gf_database_password"       = local.rds_password
    "gf_security_admin_email"    = local.secrets.gf_security_admin_email
    "gf_security_admin_password" = local.secrets.gf_security_admin_password
    "gf_security_admin_user"     = local.secrets.gf_security_admin_user
  }

  task_secrets_arn_map = {
    for s in module.grafana_secrets.secrets : trimprefix(s.name, "/${local.resource_prefix}/") => s.arn
  }

  task_secrets = [
    { "name" : "GF_DATABASE_USER", "valueFrom" : "${local.task_secrets_arn_map.gf_database_user}" },
    { "name" : "GF_DATABASE_PASSWORD", "valueFrom" : "${local.task_secrets_arn_map.gf_database_password}" },
    { "name" : "GF_SECURITY_ADMIN_EMAIL", "valueFrom" : "${local.task_secrets_arn_map.gf_security_admin_email}" },
    { "name" : "GF_SECURITY_ADMIN_PASSWORD", "valueFrom" : "${local.task_secrets_arn_map.gf_security_admin_password}" },
    { "name" : "GF_SECURITY_ADMIN_USER", "valueFrom" : "${local.task_secrets_arn_map.gf_security_admin_user}" }
  ]

  task_environment = [
    { "name" : "GF_DATABASE_HOST", "value" : "${module.grafana_rds.rds_endpoint}" },
    { "name" : "GF_DATABASE_NAME", "value" : "${local.rds_db_name}" },
    { "name" : "GF_LOG_MODE", "value" : "${var.gf_log_mode}" },
    { "name" : "GF_LOG_USER_FACING_DEFAULT_ERROR", "value" : "${var.gf_log_user_facing_default_error}" },
    { "name" : "GF_SECURITY_COOKIE_SECURE", "value" : tostring(var.gf_security_cookie_secure) },
    { "name" : "GF_SECURITY_DISABLE_GRAVATAR", "value" : tostring(var.gf_security_disable_gravatar) },
    { "name" : "GF_SECURITY_STRICT_TRANSPORT_SECURITY", "value" : tostring(var.gf_security_strict_transport_security) },
    { "name" : "GF_SECURITY_STRICT_TRANSPORT_SECURITY_SUBDOMAINS", "value" : tostring(var.gf_security_strict_transport_security_subdomains) },
    { "name" : "GF_SNAPSHOTS_ENABLED", "value" : tostring(var.gf_snapshots_enabled) },
  ]
}
