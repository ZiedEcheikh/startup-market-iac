/*resource "aws_ecs_task_definition" "auth_server_task_definition" {

  task_role_arn = aws_iam_role.ecs_auth_svr_task_role.arn
  }

  resource "aws_iam_policy" "ecs_exec_task_policy" {
  name        = "ecs-exec-task-policy"
  description = "ECS task policy to allow access to SSM and CloudWatch logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
        "ssmmessages:CreateDataChannel",
        "ssmmessages:OpenControlChannel",
        "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_ecs_service" "auth_server_service" {
  enable_execute_command = true
}
*/

resource "aws_iam_role" "ecs_auth_svr_task_role" {
  name = "ecs-auth-svr-task-role"
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



resource "aws_iam_role_policy_attachment" "ecs_task_role_attachment" {
  role       = aws_iam_role.ecs_auth_svr_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_task_policy.arn
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = "var.vpc_id"
  service_name       = "com.amazonaws.eu-west-3.ssm"
  vpc_endpoint_type  = "Interface"
  subnet_ids         = "var.subnets"
  security_group_ids = [aws_security_group.auth_server_sg.id]
}
 ./check-ecs-exec.sh esc_market_fargate_cluster 4bf75d813abf4c74a94acc630d113dbf

aws ecs list-tasks --cluster esc_market_fargate_cluster

aws ecs describe-tasks \
    --cluster esc_market_fargate_cluster \
    --tasks 4bf75d813abf4c74a94acc630d113dbf


aws ecs execute-command --cluster esc_market_fargate_cluster --task 4bf75d813abf4c74a94acc630d113dbf --container authorization-server-container --command "/bin/sh" --interactive
