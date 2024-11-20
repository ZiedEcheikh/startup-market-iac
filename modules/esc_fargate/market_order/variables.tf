variable "environment" {
  type        = string
  description = "Environment to deploy infra"
}

variable "ghcrio_secret_arn" {
  type        = string
  description = "Github package secret arn"
}

variable "esc_cluster_id" {
  type        = string
  description = "ESC cluster id"
}

variable "ecs_task_execution_role" {
  type        = string
  description = "Execution role for task"
}

variable "vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "subnets" {
  type        = list(any)
  description = "List of sunbnets IDs"
}

variable "alb_listener_arn" {
  type        = string
  description = "Target group arn"
}

variable "alb_sg_id" {
  type        = string
  description = "Target group arn"
}

variable "alb_dns_name" {
  type        = string
  description = "ALB dns name"
}

variable "market_order_table_name" {
  type        = string
  description = "Market order table name"
}

variable "market_order_table_arn" {
  type        = string
  description = "Market order table arn"
}

variable "metadata_table_name" {
  type        = string
  description = "Metadata table name"
}

variable "metadata_table_arn" {
  type        = string
  description = "Metadata table arn"
}
