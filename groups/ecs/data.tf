data "aws_ecr_image" "grafana_image" {
  repository_name = "ci-grafana-image"
  most_recent       = true
}
