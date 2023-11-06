resource "aws_cloudwatch_log_group" "grafana_log_group" {
  name = "${local.resource_prefix}-log_group"
}
