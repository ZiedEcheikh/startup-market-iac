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
  description = "List of sunbnets id"
}

variable "region" {
  type        = string
  description = "Deployment Region"
}

variable "github_credentials" {
  type        = map(string)
  description = "Github docker package credentials"
}
