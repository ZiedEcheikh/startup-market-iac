resource "aws_ecs_task_definition" "market_gateway_router_task_definition" {
  family                   = "market-gateway-router-task-definition-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role
  container_definitions = jsonencode([
    {
      name      = "market-gateway-router-container"
      image     = "ghcr.io/ziedecheikh/market-gateway-router:sha-0746a7a"
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/market-gateway-router/${var.environment}"
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
          name  = "AUTH_SERVER_ISSUER_URI"
          value = format("http://%s/startup/authserver", var.alb_dns_name)
        },
        {
          name  = "HOST_URI"
          value = format("http://%s", var.alb_dns_name)
        },
        {
          name  = "MARKET_ORDER_SERVICE_URI"
          value = format("http://%s/market/api/v1/order", var.alb_dns_name)
        }

      ]
      repositoryCredentials = {
        credentialsParameter = var.ghcrio_secret_arn
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "esc_market_gateway_router_log_group" {
  name              = "/ecs/market-gateway-router/${var.environment}"
  retention_in_days = 1
}

resource "aws_ecs_service" "market_gateway_router_service" {
  name            = "market-gateway-router-service-${var.environment}"
  cluster         = var.esc_cluster_id
  task_definition = aws_ecs_task_definition.market_gateway_router_task_definition.arn
  desired_count   = 0
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.market_gateway_router_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.market_gateway_router_tg.arn
    container_name   = "market-gateway-router-container"
    container_port   = local.container_port
  }
}

resource "aws_lb_target_group" "market_gateway_router_tg" {
  name        = "market-gateway-router-tg-${var.environment}"
  port        = local.host_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/actuator/health"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "market_gateway_router_listner_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 11
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.market_gateway_router_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}


resource "aws_security_group" "market_gateway_router_sg" {
  name        = "market-gateway-router-sg-${var.environment}"
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
