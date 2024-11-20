resource "aws_ecs_task_definition" "auth_server_task_definition" {
  family                   = "auth-server-task-definition-${var.environment}"
  network_mode             = "awsvpc" # Use 'bridge' for EC2 tasks, or 'awsvpc' for Fargate
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256" # 0.25 vCPU
  memory                   = "512" # 0.5 GB memory
  execution_role_arn       = var.ecs_task_execution_role
  container_definitions = jsonencode([
    {
      name      = "authorization-server-container"
      image     = "ghcr.io/ziedecheikh/startup-authorization-server:sha-bd11042"
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/auth-sverver/${var.environment}"
          awslogs-region        = "eu-west-3"
          awslogs-stream-prefix = "ecs"
      } }
      portMappings = [
        {
          containerPort = local.container_port
          hostPort      = local.host_port
        }
      ]
      environment = [
        {
          name  = "HOST_URL"
          value = format("http://%s/startup/authserver", var.alb_dns_name)
        }
      ]
      repositoryCredentials = {
        credentialsParameter = var.ghcrio_secret_arn
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "esc_auth_svr_log_group" {
  name              = "/ecs/auth-sverver/${var.environment}"
  retention_in_days = 1
}

resource "aws_lb_target_group" "auth_server_tg" {
  name        = "auth-server-tg-${var.environment}"
  port        = local.host_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/startup/authserver/actuator/health"
    interval            = 90
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "auth_server_listner_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 9
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth_server_tg.arn
  }

  condition {
    path_pattern {
      values = ["/startup/authserver/*"]
    }
  }
}

resource "aws_ecs_service" "auth_server_service" {
  name            = "auth-server-service-${var.environment}"
  cluster         = var.esc_cluster_id
  task_definition = aws_ecs_task_definition.auth_server_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = var.subnets # Remplacez par vos sous-réseaux
    security_groups  = [aws_security_group.auth_server_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.auth_server_tg.arn
    container_name   = "authorization-server-container"
    container_port   = local.container_port
  }
}


resource "aws_security_group" "auth_server_sg" {
  name        = "auth-server-security-group-${var.environment}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id
  ingress {
    from_port       = local.host_port
    to_port         = local.container_port
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
