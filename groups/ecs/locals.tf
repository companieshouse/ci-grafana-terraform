locals {
  secrets     = data.vault_generic_secret.secrets.data

  placement_subnet_cidrs = values(zipmap(
    values(data.aws_subnet.placement).*.availability_zone,
    values(data.aws_subnet.placement).*.cidr_block
  ))
  placement_subnet_ids = values(zipmap(
    values(data.aws_subnet.placement).*.availability_zone,
    values(data.aws_subnet.placement).*.id
  ))
  placement_subnet_pattern  = local.secrets.placement_subnet_pattern
  placement_vpc_pattern     = local.secrets.placement_vpc_pattern
  automation_subnet_pattern = local.secrets.automation_subnet_pattern
  automation_vpc_pattern    = local.secrets.automation_vpc_pattern

  create_ssl_certificate      = var.ssl_certificate_name == "" ? true : false
  ssl_certificate_arn         = var.ssl_certificate_name == "" ? aws_acm_certificate_validation.certificate[0].certificate_arn : data.aws_acm_certificate.certificate[0].arn

  dns_zone_name               = local.secrets.dns_zone_name
  ecs_grafana_family          = "${var.service}-task"

}
