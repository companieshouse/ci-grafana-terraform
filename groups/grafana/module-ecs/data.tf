data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.account_name}/${var.region}/${var.environment}/${var.service}"
}

data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "aws_vpc" "placement" {
  filter {
    name   = "tag:Name"
    values = [local.placement_vpc_pattern]
  }
}

data "aws_subnet" "placement" {
  for_each = toset(data.aws_subnets.placement.ids)
  id = each.value
}

data "aws_subnets" "placement" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.placement.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.placement_subnet_pattern]
  }
}

data "aws_route53_zone" "selected" {
  name         = local.dns_zone_name
  private_zone = false
}

data "aws_acm_certificate" "certificate" {
  count       = local.create_ssl_certificate ? 0 : 1
  domain      = var.ssl_certificate_name
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_ec2_managed_prefix_list" "administration" {
  filter {
    name   = "prefix-list-name"
    values = ["administration-cidr-ranges"]
  }
}

data "aws_db_instance" "grafana_rds" {
  db_instance_identifier = "${local.resource_prefix}-${var.db_engine}"
}

data "aws_ssm_parameter" "database_username" {
  name = "/${var.environment}/${var.service}/rds/username"
}

data "aws_ssm_parameter" "database_password" {
  name = "/${var.environment}/${var.service}/rds/password"
}
