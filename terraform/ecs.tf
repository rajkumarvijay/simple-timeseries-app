resource "aws_ecs_cluster" "this" {
  name = "simple-timeservice-cluster"
}

# Security groups
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP inbound"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "task_sg" {
  name        = "task-sg"
  description = "Allow traffic from ALB"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Task definition (Fargate)
resource "aws_ecs_task_definition" "this" {
  family                   = "simple-timeservice-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 512 MB
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = "simple-timeservice"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/simple-timeservice"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/simple-timeservice"
  retention_in_days = 7
}

# ALB target group (targets are ECS tasks)
resource "aws_lb_target_group" "tg" {
  name     = "simple-timeservice-tg"
  port     = var.container_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  target_type = "ip"
  health_check {
    path                = "/"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_ecs_service" "this" {
  name            = "simple-timeservice-svc"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets         = local.private_subnet_ids
    security_groups = [aws_security_group.task_sg.id]
    assign_public_ip = false   # IMPORTANT: tasks run in private subnets only
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "simple-timeservice"
    container_port   = var.container_port
  }

  depends_on = [aws_lb_listener.listener]
}
