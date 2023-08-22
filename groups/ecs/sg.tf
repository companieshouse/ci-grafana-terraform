resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-${var.service}-lb"
  description = "Restricts access for ${var.service}-${var.environment} lb ${var.service} nodes"
  vpc_id      = data.aws_vpc.placement.id

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
