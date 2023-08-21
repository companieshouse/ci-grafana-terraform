locals {
  account_ids = data.vault_generic_secret.account_ids.data
  secrets     = data.vault_generic_secret.secrets.data

  placement_subnet_cidrs = values(zipmap(
    values(data.aws_subnet.placement).*.availability_zone,
    values(data.aws_subnet.placement).*.cidr_block
  ))
  placement_subnet_ids = values(zipmap(
    values(data.aws_subnet.placement).*.availability_zone,
    values(data.aws_subnet.placement).*.id
  ))
  placement_subnet_pattern = local.secrets.placement_subnet_pattern
  placement_vpc_pattern    = local.secrets.placement_vpc_pattern

  automation_subnet_cidrs = values(zipmap(
    values(data.aws_subnet.automation).*.availability_zone,
    values(data.aws_subnet.automation).*.cidr_block
  ))
  automation_subnet_ids = values(zipmap(
    values(data.aws_subnet.automation).*.availability_zone,
    values(data.aws_subnet.automation).*.id
  ))
  automation_subnet_pattern = local.secrets.automation_subnet_pattern
  automation_vpc_pattern    = local.secrets.automation_vpc_pattern

  create_ssl_certificate      = var.ssl_certificate_name == "" ? true : false
  ssl_certificate_arn         = var.ssl_certificate_name == "" ? aws_acm_certificate_validation.certificate[0].certificate_arn : data.aws_acm_certificate.certificate[0].arn

  dns_zone_name               = local.secrets.dns_zone_name
  load_balancer_dns_zone_name = local.secrets.load_balancer_dns_zone_name

  image_owner_id = local.secrets.image_owner_id
  grafana_image = "${local.image_owner_id}.dkr.ecr.${var.region}.amazonaws.com/${var.image_repository_name}:${var.grafana_image_version}"

}
