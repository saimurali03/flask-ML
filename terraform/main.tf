#########################################
# Provider
#########################################
provider "aws" {
  region = var.aws_region
}

#########################################
# Default VPC + Subnets + SG
#########################################
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_groups" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

#########################################
# ECR Repository
#########################################
resource "aws_ecr_repository" "this" {
  name = "flask-ml-api"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    project = "flask-ml-cicd"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, image_scanning_configuration]
  }
}

#########################################
# IAM Role for ECS Tasks
#########################################
data "aws_iam_policy_document" "task_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task_exec_role" {
  name               = "ecsTaskExecutionRole-flask-ml"
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json

  lifecycle {
    prevent_destroy = true
    ignore_changes = [assume_role_policy]
  }
}

resource "aws_iam_role_policy_attachment" "task_exec_attach" {
  role       = aws_iam_role.task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

  lifecycle {
    prevent_destroy = true
  }
}

#########################################
# CloudWatch Logs
#########################################
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/flask-ml"
  retention_in_days = 14

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name]
  }
}

#########################################
# ECS Cluster
#########################################
resource "aws_ecs_cluster" "this" {
  name = "flask-ml-cluster"
}

#########################################
# Task Definition
#########################################
resource "aws_ecs_task_definition" "task" {
  family                   = "flask-ml-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.task_exec_role.arn

  container_definitions = jsonencode([{
    name      = "flask-ml-api"
    image     = "${var.ecr_repo_url}:${var.image_tag}"
    essential = true
    portMappings = [{
      containerPort = 5000
      hostPort      = 5000
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = "/ecs/flask-ml"
        awslogs-region        = var.aws_region
        awslogs-stream-prefix = "flask"
      }
    }
  }])
}

#########################################
# Application Load Balancer
#########################################
resource "aws_lb" "alb" {
  name               = "flask-ml-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups    = [element(data.aws_security_groups.default.ids, 0)]
}

resource "aws_lb_target_group" "tg" {
  name     = "flask-ml-tg"
  port     = 5000
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path = "/"
    port = "5000"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

#########################################
# ECS Service WITH ALB ATTACHED
#########################################
resource "aws_ecs_service" "service" {
  name            = "flask-ml-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = data.aws_subnets.default.ids
    assign_public_ip = true
    security_groups  = [element(data.aws_security_groups.default.ids, 0)]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "flask-ml-api"
    container_port   = 5000
  }

  depends_on = [
    aws_lb_listener.listener,
    aws_iam_role_policy_attachment.task_exec_attach,
    aws_ecs_task_definition.task
  ]
}
