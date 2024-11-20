resource "aws_ecs_task_definition" "market_order_task_definition" {
  family                   = "market-order-task-definition-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = var.ecs_task_execution_role
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([
    {
      name      = "market-order-service-container"
      image     = "ghcr.io/ziedecheikh/market-order-service:sha-3df4cb7"
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/market-order-service/${var.environment}"
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
          name  = "TABLE_NAME_MARKET_ORDER"
          value = var.market_order_table_name
        },
        {
          name  = "TABLE_NAME_METADATA"
          value = var.metadata_table_name
        }

      ]
      repositoryCredentials = {
        credentialsParameter = var.ghcrio_secret_arn
      }
    }
  ])
}

resource "aws_cloudwatch_log_group" "esc_market_order_service_log_group" {
  name              = "/ecs/market-order-service/${var.environment}"
  retention_in_days = 1
}

resource "aws_ecs_service" "market_order_service" {
  name            = "market-order-service-${var.environment}"
  cluster         = var.esc_cluster_id
  task_definition = aws_ecs_task_definition.market_order_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.subnets
    security_groups  = [aws_security_group.market_order_service_sg.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.market_order_service_tg.arn
    container_name   = "market-order-service-container"
    container_port   = local.container_port
  }
}

resource "aws_lb_target_group" "market_order_service_tg" {
  name        = "market-order-service-tg-${var.environment}"
  port        = local.host_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/market/api/v1/actuator/health"
    interval            = 60
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener_rule" "market_order_service_listner_rule" {
  listener_arn = var.alb_listener_arn
  priority     = 8
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.market_order_service_tg.arn
  }

  condition {
    path_pattern {
      values = ["/market/api/v1/*"]
    }
  }
}


resource "aws_security_group" "market_order_service_sg" {
  name        = "market-order-service-sg-${var.environment}"
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

resource "aws_iam_policy" "ecs_task_dynamodb_policy" {
  name        = "ecs-task-dynamodb-access"
  description = "Allow ECS Task to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ],
        Resource = [var.market_order_table_arn, "${var.market_order_table_arn}/index/*", var.metadata_table_arn]
      }
    ]
  })
}


resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_dynamodb_policy_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_dynamodb_policy.arn
}
