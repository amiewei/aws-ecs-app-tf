provider "aws" {
  region = var.aws_region
}


module "ecs" {
  source                    = "./modules/ecs"
  aws_region                = var.aws_region
  ecs_task_count            = var.ecs_task_count
  ecs_cluster_name          = var.ecs_cluster_name
  cloudwatch_group_name     = var.cloudwatch_group_name
  execution_role_arn        = module.iam.ecs_task_execution_role_arn
  target_group_arn          = module.networking.target_group_arn
  service_security_group_id = module.networking.service_security_group_id
  default_subnet_a_id       = module.networking.default_subnet_a_id
  default_subnet_c_id       = module.networking.default_subnet_c_id
}


module "iam" {
  source = "./modules/iam"
}

module "networking" {
  source     = "./modules/networking"
  aws_region = var.aws_region
}

module "logging" {
  source                = "./modules/logging"
  cloudwatch_group_name = var.cloudwatch_group_name
}

