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
}
