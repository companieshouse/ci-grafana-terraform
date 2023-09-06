resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = local.fqdn
  type    = "A"

  alias {
    name                   = aws_lb.grafana_lb.dns_name
    zone_id                = aws_lb.grafana_lb.zone_id
    evaluate_target_health = false
  }
}
