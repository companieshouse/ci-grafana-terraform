resource "aws_security_group" "alb_security_group" {
  lifecycle {
    create_before_destroy = true
  }

  name        = "${local.resource_prefix}-lb-sg"
  description = "Restricts access for ${local.resource_prefix} lb ${var.service} nodes"
  vpc_id      = data.aws_vpc.placement.id

  ingress {
    description     = "lb HTTPS ingress from admin CIDRs"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.administration.id]
  }

  ingress {
    description     = "lb HTTP ingress from admin CIDRs"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.administration.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  lifecycle {
    create_before_destroy = true
  }

  name        = "${local.resource_prefix}-ecs-tasks-sg"
  description = "ECS Tasks Security Group"
  vpc_id      = data.aws_vpc.placement.id

  ingress {
    from_port   = 1024
    to_port     = 65535
    protocol    = "tcp"
    prefix_list_ids = [data.aws_ec2_managed_prefix_list.administration.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
