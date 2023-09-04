resource "aws_ecs_cluster" "tfc_ecs_cluster" {
  # name = "tfc-app-cluster"
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = var.execution_role_arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "app-task",
      "image": "303952242443.dkr.ecr.us-east-1.amazonaws.com/tf-ecs-app-repo:latest",
      "essential": true,
      "portMappings": [
        {
          "containerPort": 5000,
          "hostPort": 5000
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "${var.cloudwatch_group_name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
          }
      }
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "app_service" {
  name            = "app-first-service"
  cluster         = aws_ecs_cluster.tfc_ecs_cluster.id
  task_definition = aws_ecs_task_definition.app_task.arn
  launch_type     = "FARGATE"
  desired_count   = var.ecs_task_count

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = aws_ecs_task_definition.app_task.family
    container_port   = 5000
  }

  network_configuration {
    subnets          = ["${var.default_subnet_a_id}", "${var.default_subnet_c_id}"]
    assign_public_ip = true # Container needs public IP so it can be accessed
    security_groups  = ["${var.service_security_group_id}"]
  }
}

