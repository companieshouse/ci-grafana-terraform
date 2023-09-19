resource "aws_ssm_parameter" "database_username" {
  name        = "/${var.environment}/${var.service}/rds/username"
  description = "The database username"
  type        = "SecureString"
  value       = local.db_username
}

resource "aws_ssm_parameter" "database_password" {
  name        = "/${var.environment}/${var.service}/rds/password"
  description = "The database password"
  type        = "SecureString"
  value       = local.db_password
}
