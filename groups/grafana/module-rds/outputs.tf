output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "rds_engine_version" {
  value = "${aws_db_instance.rds.engine}-${aws_db_instance.rds.engine_version_actual}"
}

output "rds_security_group_name" {
  value = aws_security_group.rds.name
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}
