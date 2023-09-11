locals {
  name   = "ecsdemo-frontend"
  region = var.aws_region

  container_image = var.container_image
  container_port  = var.container_port
  container_name  = local.name

  tags = {
    Blueprint = local.name
  }
}

module "service_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.3"

  name = "${local.name}-alb"

  load_balancer_type = "application"

  vpc_id  = var.vpc_id
  subnets = var.public_subnets
  security_group_rules = {
    ingress_all_http = {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "HTTP web traffic"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [for s in var.private_subnets_cidr_blocks : s]
    }
  }

  http_tcp_listeners = [{
    port               = "80"
    protocol           = "HTTP"
    target_group_index = 0
  }]

  target_groups = [{
    name             = "${local.name}-tg"
    backend_protocol = "HTTP"
    backend_port     = local.container_port
    target_type      = "ip"
    health_check = {
      path    = "/"
      port    = local.container_port
      matcher = "200-299"
    }
  }]

  tags = local.tags
}

resource "aws_service_discovery_service" "this" {
  name = local.name

  dns_config {
    namespace_id = var.service_discovery_namespaces

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

module "ecs_service_definition" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.0"

  name               = local.name
  desired_count      = var.ecs_task_count
  cluster_arn        = var.ecs_cluster_arn
  enable_autoscaling = false

  subnet_ids = var.private_subnets
  security_group_rules = {
    ingress_alb_service = {
      type                     = "ingress"
      from_port                = local.container_port
      to_port                  = local.container_port
      protocol                 = "tcp"
      description              = "Service port"
      source_security_group_id = module.service_alb.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  load_balancer = [{
    container_name   = local.container_name
    container_port   = local.container_port
    target_group_arn = element(module.service_alb.target_group_arns, 0)
  }]

  service_registries = {
    registry_arn = aws_service_discovery_service.this.arn
  }

  # Task Definition
  create_iam_role        = false
  task_exec_iam_role_arn = var.ecs_task_execution_role_arn
  enable_execute_command = true

  container_definitions = {
    main_container = {
      name                     = local.container_name
      image                    = local.container_image
      readonly_root_filesystem = false

      port_mappings = [{
        protocol : "tcp",
        containerPort : local.container_port
        hostPort : local.container_port
      }]
    }
  }

  ignore_task_definition_changes = false

  tags = local.tags
}

