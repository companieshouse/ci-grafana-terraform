resource "aws_kms_key" "grafana" {
  description = "Encryption key for ${local.resource_prefix}"
}

resource "aws_kms_alias" "grafana" {
  name          = "alias/${local.resource_prefix}-kms-key"
  target_key_id = aws_kms_key.grafana.key_id
}
