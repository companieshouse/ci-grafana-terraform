resource "aws_security_group" "rds" {
  name        = "${local.resource_prefix}-rds"
  description = "Security group for ${local.resource_prefix} rds"
  vpc_id      = var.vpc_id

  #  egress {
  #    description = "Allow outbound traffic"
  #    from_port   = 0
  #    to_port     = 0
  #    protocol    = "-1"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }

  tags = merge(
    local.default_tags,
    {
      Name = "${local.resource_prefix}-rds"
    }
  )
}

resource "aws_security_group_rule" "ingress_cidrs" {
  for_each = toset(var.ingress_cidrs)

  description       = "Permit RDS access from ${each.value}"
  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.rds.id
}

resource "aws_security_group_rule" "ingress_prefix_lists" {
  for_each = toset(var.ingress_prefix_list_ids)

  description       = "Permit RDS access from ${each.value}"
  type              = "ingress"
  from_port         = local.port
  to_port           = local.port
  protocol          = "tcp"
  prefix_list_ids   = [each.value]
  security_group_id = aws_security_group.rds.id
}
