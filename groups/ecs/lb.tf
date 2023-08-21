resource "aws_lb" "grafana_lb" {
  name               = "grafana-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["sg-abc123abc"]
  subnets            = local.placement_subnet_cidrs
  enable_deletion_protection = true
}

resource "aws_lb_target_group" "grafana_tg" {
  name     = "grafana-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.placement.id

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 30
    interval            = 60
    path                = "/"
  }
}

resource "aws_lb_listener" "grafana_listener" {
  load_balancer_arn = aws_lb.grafana_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = local.ssl_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}

resource "aws_acm_certificate" "certificate" {
  count = local.create_ssl_certificate ? 1 : 0

  domain_name               = "${var.service}.${var.environment}.${data.aws_route53_zone.selected.name}"
  subject_alternative_names = ["*.${var.service}.${var.environment}.${data.aws_route53_zone.selected.name}"]
  validation_method         = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  for_each = local.create_ssl_certificate ? {
    for dvo in aws_acm_certificate.certificate[0].domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      type    = dvo.resource_record_type
      record  = dvo.resource_record_value
    }
  } : {}

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.selected.id
}

resource "aws_acm_certificate_validation" "certificate" {
  count = local.create_ssl_certificate ? 1 : 0

  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = [for record in aws_route53_record.certificate_validation : record.fqdn]
}
