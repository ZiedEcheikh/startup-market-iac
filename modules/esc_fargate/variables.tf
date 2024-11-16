variable "environment" {
  type        = string
  description = "Environment to deploy infra"
}

variable "vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "subnets" {
  type        = list(any)
  description = "List of sunbnets IDs"
}

variable "ghcrio_secret_arn" {
  type        = string
  description = "Github package secret arn"
}
