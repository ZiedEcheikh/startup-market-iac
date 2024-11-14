variable "vpc_id" {
  type        = string
  description = "Vpc id"
}

variable "subnets" {
  type        = list(any)
  description = "List of sunbnets id"
}

variable "github_credentials" {
  type        = map(string)
  description = "Github docker package credentials"
}

variable "region" {
  type        = string
  description = "Deployment Region"
}
