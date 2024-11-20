module "secrets" {
  source             = "./modules/secret"
  github_credentials = var.github_credentials
}

module "dyn_table_market_order" {
  source      = "./modules/dynamodb/market_order"
  environment = var.environment
}

module "dyn_table_metadata" {
  source      = "./modules/dynamodb/metadata"
  environment = var.environment
}

module "ecs_services" {
  source                  = "./modules/esc_fargate"
  ghcrio_secret_arn       = module.secrets.arn_ghcrio_credentials
  vpc_id                  = var.vpc_id
  subnets                 = var.subnets
  environment             = var.environment
  market_order_table_name = module.dyn_table_market_order.market_order_table_name
  market_order_table_arn  = module.dyn_table_market_order.market_order_table_arn
  metadata_table_name     = module.dyn_table_metadata.metadata_table_name
  metadata_table_arn      = module.dyn_table_metadata.metadata_table_arn
}
