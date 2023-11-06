resource "aws_ecs_cluster" "grafana_cluster" {
  name = "${local.resource_prefix}-cluster"
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "${local.resource_prefix}-task"
  network_mode             = var.ecs_grafana_network_mode
  requires_compatibilities = [var.ecs_grafana_launch_type]
  cpu                      = var.ecs_grafana_cpu
  memory                   = var.ecs_grafana_memory

  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions    = jsonencode(
    [
      {
        name         = local.container_name,
        image        = "${var.ecr_repository}:${var.grafana_image_version}",
        cpu          = 10
        memory       = 512
        essential    = true,
        portMappings = [
          {
            "containerPort" = 3000,
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options   = {
            awslogs-group         = aws_cloudwatch_log_group.grafana_log_group.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "ecs"
        }
      },
        secrets = [
          {
            name      = "GF_DATABASE_USER",
            valueFrom = data.aws_ssm_parameter.database_username.arn
          },
          {
            name      = "GF_DATABASE_PASSWORD",
            valueFrom = data.aws_ssm_parameter.database_password.arn
          },
        ],
        environment = [
          {
            name      = "GF_DATABASE_HOST",
            value     = data.aws_db_instance.grafana_rds.endpoint
          },
          {
            name      = "GF_DATABASE_NAME"
            value     = data.aws_db_instance.grafana_rds.db_name
          },
          {
            name      = "GF_DATABASE_TYPE"
            value     = data.aws_db_instance.grafana_rds.engine
          },


        ],

      }
    ]
  )
}

resource "aws_ecs_service" "grafana_service" {
  name                              = "${local.resource_prefix}-service"
  cluster                           = aws_ecs_cluster.grafana_cluster.id
  task_definition                   = aws_ecs_task_definition.grafana_task.arn
  launch_type                       = var.ecs_grafana_launch_type
  platform_version                  = "LATEST"
  desired_count                     = var.grafana_service_desired_count
  health_check_grace_period_seconds = 120
  depends_on                        = [
    aws_iam_role.ecs_execution_role,
  ]

  network_configuration {
    subnets          = local.placement_subnet_ids
    assign_public_ip = false
    security_groups = [
      aws_security_group.ecs_tasks_sg.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.grafana_tg.arn
    container_name = local.container_name
    container_port = 3000
  }

}

resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.grafana_cluster.name}/${aws_ecs_service.grafana_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy" {
  name               = "${local.resource_prefix}-cpu-utilization"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
