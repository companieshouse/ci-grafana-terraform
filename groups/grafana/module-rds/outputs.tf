output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

output "rds_engine_version" {
  value = "${aws_db_instance.rds.engine}-${aws_db_instance.rds.engine_version_actual}"
}
