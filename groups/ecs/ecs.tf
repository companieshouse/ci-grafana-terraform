resource "aws_ecs_cluster" "grafana_cluster" {
  name = "grafana-cluster"
}

resource "aws_ecs_task_definition" "grafana_task" {
  family                = "grafana_task"
  network_mode          = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = "256"
  memory = "512"

  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "grafana-container",
      "image": "${local.image_owner_id}.dkr.ecr.${var.region}.amazonaws.com/${var.image_repository_name}:${var.grafana_image_version}",
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
  name            = "grafana-service"
  cluster         = aws_ecs_cluster.grafana_cluster.id
  task_definition = aws_ecs_task_definition.grafana_task.arn
  launch_type     = "FARGATE"
  depends_on = [
    aws_iam_role.ecs_execution_role,
  ]
  desired_count = 1

  network_configuration {
    subnets = local.placement_subnet_cidrs
    assign_public_ip = false
  }

}
