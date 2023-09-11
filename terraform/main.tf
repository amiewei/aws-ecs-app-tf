provider "aws" {
  region = var.aws_region
}

module "core_infra" {
  source     = "./core-infra"
  aws_region = var.aws_region
  num_az     = 2

}

module "lb_service" {
  source = "./lb-service"

  container_image = "303952242443.dkr.ecr.us-east-1.amazonaws.com/tf-ecs-app-repo:latest"
  container_port  = 5000
  aws_region      = var.aws_region
  ecs_task_count  = 3

  # Pass in dependencies to ensure core-infra gets created first
  vpc_id                       = module.core_infra.vpc_id
  public_subnets               = module.core_infra.public_subnets
  private_subnets              = module.core_infra.private_subnets
  ecs_cluster_name             = module.core_infra.ecs_cluster_name
  ecs_cluster_arn              = module.core_infra.ecs_cluster_id
  ecs_task_execution_role_name = module.core_infra.ecs_task_execution_role_name
  ecs_task_execution_role_arn  = module.core_infra.ecs_task_execution_role_arn
  service_discovery_namespaces = module.core_infra.service_discovery_namespaces.id
  private_subnets_cidr_blocks  = module.core_infra.private_subnets_cidr_blocks

}
