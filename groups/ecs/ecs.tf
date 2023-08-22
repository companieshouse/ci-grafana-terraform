resource "aws_ecs_cluster" "grafana_cluster" {
  name = "${var.service}-cluster"
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                   = "${var.service}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"

  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions    = <<DEFINITION
  [
    {
      "name": "grafana-container",
      "image": "${var.ecr_repository}:${var.grafana_image_version}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ]
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "grafana_service" {
  name                              = "${var.service}-service"
  cluster                           = aws_ecs_cluster.grafana_cluster.id
  task_definition                   = aws_ecs_task_definition.grafana_task.arn
  launch_type                       = "FARGATE"
  desired_count                     = 1
  depends_on                        = [
    aws_iam_role.ecs_execution_role,
  ]

  network_configuration {
    subnets          = local.placement_subnet_ids
    assign_public_ip = false
  }

}
