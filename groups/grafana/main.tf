terraform {
  required_version = ">= 1.3.0, < 2.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.12.0, < 6.0"
    }
  }
  backend "s3" {}
}

module "grafana_rds" {
  source = "git@github.com:companieshouse/terraform-modules//aws/rds_instance?ref=1.0.238"

  environment             = var.environment
  service                 = var.service

  vpc_id                  = data.aws_vpc.vpc.id
  subnet_ids              = data.aws_subnets.deployment.ids
  ingress_cidrs           = local.ingress_cidrs
  ingress_prefix_list_ids = local.ingress_prefix_list_ids

  db_name                 = local.rds_db_name
  username                = local.rds_username
  password                = local.rds_password
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = var.rds_backup_window
  deletion_protection     = var.rds_deletion_protection
  engine                  = var.rds_engine
  engine_major_version    = var.rds_engine_major_version
  engine_minor_version    = var.rds_engine_minor_version
  instance_class          = var.rds_instance_class
  maintenance_window      = var.rds_maintenance_window
  allocated_storage       = var.rds_allocated_storage
  skip_final_snapshot     = true
}

module "grafana_alb" {
  source = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.238"

  environment             = var.environment
  service                 = var.service

  vpc_id                  = data.aws_vpc.vpc.id
  subnet_ids              = data.aws_subnets.deployment.ids
  ingress_prefix_list_ids = local.ingress_prefix_list_ids

  create_security_group   = true
  redirect_http_to_https  = true
  ssl_certificate_arn     = data.aws_acm_certificate.certificate[0].arn

  service_configuration = {
    listener_config = {
      port = 443
    },
    target_group_config = {
      port        = var.ecs_task_port
      target_type = "ip"
      health_check = {
        healthy_threshold   = 3
        unhealthy_threshold = 3
        path                = local.healthcheck_path
        port                = var.ecs_task_port
      }
    }
  }
}

module "grafana_secrets" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/secrets?ref=1.0.238"

  name_prefix = local.resource_prefix
  environment = var.environment
  kms_key_id  = aws_kms_alias.grafana.arn
  secrets     = local.parameter_store_secrets
}

module "grafana_ecs" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/ecs-service?ref=1.0.238"

  # Environmental configuration
  environment             = var.environment
  aws_region              = var.aws_region
  aws_profile             = "${var.aws_account}-${var.aws_region}"
  vpc_id                  = data.aws_vpc.vpc.id
  ecs_cluster_id          = data.aws_ecs_cluster.ecs.id
  task_execution_role_arn = data.aws_iam_role.ecs_cluster_iam_role.arn

  # Load balancer configuration
  lb_listener_arn           = module.grafana_alb.application_load_balancer_listener_arns["443"]
  lb_listener_rule_priority = local.lb_listener_rule_priority
  lb_listener_paths         = local.lb_listener_paths

  # Docker container details
  docker_registry   = var.ecr_image_registry
  docker_repo       = var.ecr_image_repository
  container_version = var.ecr_image_version
  container_port    = var.ecs_task_port

  # Service configuration
  service_name                = var.service
  name_prefix                 = local.name_prefix
  use_fargate                 = var.ecs_use_fargate
  fargate_subnets             = data.aws_subnets.deployment.ids
  fargate_ingress_cidrs       = local.ingress_cidrs
  fargate_permit_existing_alb = false

  # Service Healthcheck configuration
  healthcheck_path                  = local.healthcheck_path
  healthcheck_matcher               = local.healthcheck_matcher
  health_check_grace_period_seconds = 300

  # Service performance and scaling configs
  desired_task_count = var.ecs_task_desired_count
  required_cpus      = var.ecs_task_required_cpus
  required_memory    = var.ecs_task_required_memory

  # Service environment variable and secret configs
  task_environment = local.task_environment
  task_secrets     = local.task_secrets

  depends_on = [
    module.grafana_secrets,
    module.grafana_alb
  ]
}
