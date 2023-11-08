data "vault_generic_secret" "account_ids" {
  path = "aws-accounts/account-ids"
}

data "vault_generic_secret" "secrets" {
  path = "team-${var.team}/${var.aws_account}/${var.aws_region}/${var.environment}/${var.service}"
}


data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_pattern]
  }
}

data "aws_subnets" "deployment" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  filter{
    name   = "tag:Name"
    values = [local.subnet_pattern]
  }
}

data "aws_subnet" "deployment" {
  for_each = toset(data.aws_subnets.deployment.ids)

  id = each.value
}

data "aws_ec2_managed_prefix_list" "admin" {
  filter {
    name   = "prefix-list-name"
    values = ["administration-cidr-ranges"]
  }
}
