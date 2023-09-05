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
        name : "${local.resource_prefix}-container",
        image : "${var.ecr_repository}:${var.grafana_image_version}",
        essential : true,
        portMappings : [
          {
            "containerPort": 3000,
            "hostPort": 3000
          }
        ]
      }
    ]
  )
}

#resource "aws_ecs_service" "grafana_service" {
#  name                              = "${local.resource_prefix}-service"
#  cluster                           = aws_ecs_cluster.grafana_cluster.id
#  task_definition                   = aws_ecs_task_definition.grafana_task.arn
#  launch_type                       = var.ecs_grafana_launch_type
#  desired_count                     = var.grafana_service_desired_count
#  depends_on                        = [
#    aws_iam_role.ecs_execution_role,
#  ]
#
#  network_configuration {
#    subnets          = local.placement_subnet_ids
#    assign_public_ip = false
#    security_groups = [
#      aws_security_group.alb_security_group.arn,
#    ]
#  }
#
#  load_balancer {
#    target_group_arn = aws_lb_target_group.grafana_tg.arn
#    container_name = "${local.resource_prefix}-container"
#    container_port = 3000
#  }
#
#}
