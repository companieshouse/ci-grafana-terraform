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
        name = local.container_name,
        image = "${var.ecr_repository}:${var.grafana_image_version}",
        cpu       = 10
        memory    = 512
        essential = true,
        portMappings = [
          {
            "containerPort" = 3000,
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.grafana_log_group.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "ecs"
        }
      }
      }
    ]
  )
}

resource "aws_ecs_service" "grafana_service" {
  name                              = "${local.resource_prefix}-service"
  cluster                           = aws_ecs_cluster.grafana_cluster.id
  task_definition                   = aws_ecs_task_definition.grafana_task.arn
  launch_type                       = var.ecs_grafana_launch_type
  desired_count                     = var.grafana_service_desired_count
  health_check_grace_period_seconds = 600
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
