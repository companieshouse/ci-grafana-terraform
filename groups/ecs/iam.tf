data "aws_iam_policy_document" "ecs_execution_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_execution_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ssm:GetParameters",
    ]
    resources = [
      "*",
      "arn:aws:ecr:eu-west-2:416670754337:repository/ci-grafana-image",
    ]
  }
}


data "aws_iam_policy_document" "ecs_task_role_policy" {
  statement {
    effect  = "Allow"
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ecs_task_permissions" {
  statement {
    effect    = "Allow"
    actions   = [
      "cloudwatch:ListMetrics",
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:cloudwatch:*:*:metric/${local.resource_prefix}*"]
  }
}


resource "aws_iam_policy" "ecs_task_permissions" {
  name        = "${local.resource_prefix}-ECSTaskPermissions"
  description = "Permissions for ECS Task Role"
  policy      = data.aws_iam_policy_document.ecs_task_permissions.json
}


resource "aws_iam_policy" "ecs_execution_permissions" {
  name        = "${local.resource_prefix}-ECSExecutionPermissions"
  description = "Permissions for ECS Execution Role"
  policy      = data.aws_iam_policy_document.ecs_execution_permissions.json
}


resource "aws_iam_role" "ecs_execution_role" {
  name               = "${local.resource_prefix}-ecs_execution_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_execution_role_policy.json
}

resource "aws_iam_role" "ecs_task_role" {
  name               = "${local.resource_prefix}-ecs_task_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_role_policy.json
}


resource "aws_iam_role_policy_attachment" "ecs_execution_permissions_attach" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_permissions.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_permissions_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_permissions.arn
}
