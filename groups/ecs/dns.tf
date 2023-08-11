data "aws_route53_zone" "selected" {
  name = "example.com."
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "metrics"
  type    = "A"

  alias {
    name                   = aws_lb.grafana_lb.dns_name
    zone_id                = aws_lb.grafana_lb.zone_id
    evaluate_target_health = false
  }
}

data "aws_acm_certificate" "cert" {
  domain   = data.aws_route53_zone.selected.zone_id
  statuses = ["ISSUED"]
}
