variable "aws_account" {
  description = "The name of the AWS account we're using"
  type        = string
}

variable "aws_region" {
  description = "The AWS region in which resources will be created"
  type        = string
}

variable "environment" {
  description = "The environment name to be used when creating AWS resources"
  type        = string
}

variable "service" {
  description = "The service name to be used when creating AWS resources"
  type        = string
}

variable "team" {
  description = "The name of the team supporting the service"
  type        = string
}

variable "engine" {
  description = "The database engine to use"
  type        = string

  validation {
    condition     = contains(["postgres", "mariadb", "mysql"], var.engine)
    error_message = "engine must be one of [postgres, mariadb, mysql]"
  }
}

variable "engine_major_version" {
  description = "Database engine major version"
  type        = string
}

variable "engine_minor_version" {
  description = "Database engine minor version"
  type        = string
}

variable "instance_class" {
  description = "Database instance class"
  type        = string
}

variable "allocated_storage" {
  description = "Amount of storage allocated to the RDS instance in GiB"
  type        = number
}

variable "deletion_protection" {
  default     = true
  description = "Defines whether deletion protection is enabled (true) or not (false)"
  type        = bool
}

variable "backup_retention_period" {
  description = "Retention period, in days, of automated RDS backups"
  type        = number
}

variable "backup_window" {
  description = "The window during which AWS can take automated backups. Cannot overlap with `maintenance_window`"
  type        = string
}

variable "maintenance_window" {
  description = "The window during which RDS maintenance can take place. Cannot overlap with `backup_window`"
  type        = string
}

variable "ingress_cidrs" {
  description = "A list of CIDR blocks that will be permitted to connect to the RDS"
  type        = list(string)
}

variable "ingress_prefix_list_ids" {
  description = "A list of prefix list IDs that will be permitted to connect to the RDS"
  type        = list(string)
}

variable "subnet_ids" {
  description = "A list of subnet IDs that the RDS resources will be created within"
  type        = list(string)
}

variable "vpc_id" {
  description = "The ID of the VPC that resources will be deployed in to"
  type        = string
}

variable "db_name" {
  description = "The name of the database to create within the RDS"
  type        = string
}

variable "password" {
  description = "The database password"
  type        = string
}

variable "username" {
  description = "The database username"
  type        = string
}

variable "auto_minor_version_upgrade" {
  default     = false
  description = "Defines whether auto_minor_version_upgrade is enabled (true) or not (false)"
  type        = bool
}

variable "skip_final_snapshot" {
  default     = false
  description = "If the RDS is destroyed, defines whether taking a final snapshot should be skipped (true) or not (false)"
  type        = bool
}

variable "multi_az" {
  default     = false
  description = "Defines whether the RDS should be configured for multi AZ operation (true) or not (false)"
  type        = bool
}
