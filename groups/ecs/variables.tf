variable "account_name" {
  description = "The name of the AWS account we're using"
  type        = string
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "region" {
  description = "The AWS region in which resources will be created"
  type        = string
}

variable "repository_name" {
  description = "The name of the repository in which we're operating"
  default     = "ci-grafana-terraform"
  type        = string
}

variable "image_repository_name" {
  description = "The name of the repository that the container is built in"
  default     = "ci-grafana-image"
  type        = string
}

variable "service" {
  description = "The service name to be used when creating AWS resources"
  default     = "ci-grafana"
  type        = string
}

variable "team" {
  description = "The name of the team"
  default     = "platform"
  type        = string
}

variable "grafana_image_version" {
  description = "The version of the ci-grafana-image container that we are using"
  default = "latest"
}

variable "ssl_certificate_name" {
  type        = string
  description = "The name of an existing ACM certificate to use for the ELB SSL listener. Setting this disables certificate creation"
  default = ""
}
