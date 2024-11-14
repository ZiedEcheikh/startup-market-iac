module "secrets" {
  source             = "./modules/secret"
  github_credentials = var.github_credentials
}

module "ecs_services" {
  source            = "./modules/esc_fargate"
  ghcrio_secret_arn = module.secrets.arn_ghcrio_credentials
  vpc_id            = var.vpc_id
  subnets           = var.subnets
}
