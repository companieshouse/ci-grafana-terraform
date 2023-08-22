resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-${var.service}-lb"
  description = "Restricts access for ${var.service}-${var.environment} lb ${var.service} nodes"
  vpc_id      = data.aws_vpc.placement.id

  ingress {
    description     = "lb HTTPS ingress from admin and concourse CIDRs"
    from_port       = 443
    to_port         = 443
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

  tags = {
    Name    = "${var.environment}-${var.service}-lb"
    Type    = "security-group"
  }

}
