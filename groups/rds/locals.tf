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
  placement_subnet_pattern = local.secrets.placement_subnet_pattern
  placement_vpc_pattern    = local.secrets.placement_vpc_pattern

  automation_subnet_pattern = local.secrets.automation_subnet_pattern
  automation_vpc_pattern    = local.secrets.automation_vpc_pattern


  db_subnet         = local.secrets.db_subnet
  db_username       = local.secrets.db_username
  db_password       = local.secrets.db_password
  db_engine_version = "${var.db_engine_major_version}.${var.db_engine_minor_version}"
}
