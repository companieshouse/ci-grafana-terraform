#-------------------------------------------------------------------------------
# Shared vars
#-------------------------------------------------------------------------------
variable "aws_account" {
  description = "The name of the AWS account we're using"
  type        = string
}

variable "aws_region" {
  default     = "eu-west-2"
  description = "The AWS region in which resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "service" {
  description = "The service name to be used when creating AWS resources"
  default     = "grafana"
  type        = string
}

variable "team" {
  description = "The name of the team"
  default     = "platform"
  type        = string
}

#-------------------------------------------------------------------------------
# RDS vars
#-------------------------------------------------------------------------------
variable "rds_port" {
  description = "The port that the database can be reached on"
  default     = 5432
  type        = number
}

variable "rds_db_name" {
  default     = "grafana"
  description = "Name of the database to create"
  type        = string
}

variable "rds_engine" {
  description = "Database engine"
  default     = "postgres"
  type        = string
}

variable "rds_engine_major_version" {
  description = "Database engine major version"
  default     = "13"
  type        = string
}

variable "rds_engine_minor_version" {
  description = "Database engine minor version"
  default     = "10"
  type        = string
}

variable "rds_instance_class" {
  description = "Database instance class"
  default     = "db.t4g.small"
  type        = string
}

variable "rds_allocated_storage" {
  description = "Storage allocated to the RDS instance in GiB"
  default     = 20
  type        = number
}

variable "rds_deletion_protection" {
  description = "Database deletion protection"
  default     = false
  type        = bool
}

variable "rds_backup_retention_period" {
  description = "Database backup retention period"
  default     = 7
  type        = number
}

variable "rds_backup_window" {
  description = "Database backup window"
  default     = "03:00-06:00"
  type        = string
}

variable "rds_maintenance_window" {
  description = "Database maintenance window"
  default     = "Sat:00:00-Sat:03:00"
  type        = string
}

#-------------------------------------------------------------------------------
# ECS vars
#-------------------------------------------------------------------------------
variable "ecr_repository" {
  description = "The ECR repositor name for the task image"
  default     = "ci-grafana-image"
  type        = string
}

variable "ecr_image_version" {
  description = "The version of the container image to use"
  default     = "latest"
}

variable "ecs_service_desired_count" {
  description = "The number of Grafana instances we want to aim for under normal circumstances"
  default     = 1
  type        = number
}

variable "ecs_task_network_mode" {
  description = "The network_mode that the grafana task requires"
  default     = "awsvpc"
  type        = string
}

variable "ecs_task_launch_type" {
  description = "The launch_type that the grafana task requires"
  default     = "FARGATE"
  type        = string
}

variable "ecs_task_cpu" {
  description = "The amount of cpu that the grafana task requires"
  default     = 256
  type        = number
}

variable "ecs_task_memory" {
  description = "The amount of memory that the grafana task requires"
  default     = 512
  type        = number
}

variable "ssl_certificate_name" {
  description = "The name of an existing ACM certificate to use for the ELB SSL listener. Setting this disables certificate creation"
  default     = ""
  type        = string
}
