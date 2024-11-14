
resource "aws_ecs_cluster" "fargate_cluster" {
  name = "esc_market_fargate_cluster"
}


data "aws_iam_policy_document" "ecs_task_execution_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
    ]
    resources = [var.ghcrio_secret_arn]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name        = "ecs_task_execution_policy_dev"
  description = "Policy to allowed ecs task to execute"
  policy      = data.aws_iam_policy_document.ecs_task_execution_policy_document.json
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_policy.arn
}


resource "aws_lb" "alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.subnets
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Allow HTTP traffic for ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module "auth_server_service" {
  source                  = "./auth_server"
  depends_on              = [aws_lb_listener.alb_listener, aws_ecs_cluster.fargate_cluster]
  ghcrio_secret_arn       = var.ghcrio_secret_arn
  esc_cluster_id          = aws_ecs_cluster.fargate_cluster.id
  ecs_task_execution_role = aws_iam_role.ecs_task_execution_role.arn
  vpc_id                  = var.vpc_id
  subnets                 = var.subnets
  alb_listener_arn        = aws_lb_listener.alb_listener.arn
  alb_sg_id               = aws_security_group.alb_sg.id
  alb_dns_name            = aws_lb.alb.dns_name
}

module "token_generator_service" {
  source                  = "./token_generator"
  depends_on              = [aws_lb_listener.alb_listener, aws_ecs_cluster.fargate_cluster]
  ghcrio_secret_arn       = var.ghcrio_secret_arn
  esc_cluster_id          = aws_ecs_cluster.fargate_cluster.id
  ecs_task_execution_role = aws_iam_role.ecs_task_execution_role.arn
  vpc_id                  = var.vpc_id
  subnets                 = var.subnets
  alb_listener_arn        = aws_lb_listener.alb_listener.arn
  alb_sg_id               = aws_security_group.alb_sg.id
  alb_dns_name            = aws_lb.alb.dns_name
}
