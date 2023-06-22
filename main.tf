provider "aws" {
  region = "us-east-1"
}

# resource "aws_ecr_repository" "app_ecr_repo" {
#   name = "app-repo"
# }

resource "aws_ecs_cluster" "my_cluster" {
  name = "app-cluster"
}

// "image": "${aws_ecr_repository.app_ecr_repo.repository_url}",
# resource "aws_ecs_task_definition" "app_task" {
#   family                   = "app-task" 
#   container_definitions    = <<DEFINITION
#   [
#     {
#       "name": "app-task",
#       "image": "303952242443.dkr.ecr.us-east-1.amazonaws.com/tf-ecs-app-repo:v1",
#       "essential": true,
#       "portMappings": [
#         {
#           "containerPort": 5000,
#           "hostPort": 5000
#         }
#       ],
#       "memory": 512,
#       "cpu": 256,
#       "logConfiguration": {
#           "logDriver": "awslogs",
#           "options": {
#             "awslogs-group": "${var.cloudwatch_group}",
#             "awslogs-region": "us-east-1",
#             "awslogs-stream-prefix": "ecs"
#           }
#       }
#     }
#   ]
#   DEFINITION
#   requires_compatibilities = ["FARGATE"]
#   network_mode             = "awsvpc"
#   memory                   = 512
#   cpu                      = 256
#   execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
# }

resource "aws_ecs_task_definition" "app_task" {
  family                   = "app-task"
  container_definitions    = <<DEFINITION
  [
    {
      "name": "app-task",
      "image": "303952242443.dkr.ecr.us-east-1.amazonaws.com/tf-ecs-app-repo:v1",
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
            "awslogs-group": "${var.cloudwatch_group}",
            "awslogs-region": "us-east-1",
            "awslogs-stream-prefix": "ecs"
          }
      }
    }
  ]
  DEFINITION
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = 512
  cpu                      = 256
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
}


resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.ecsTaskExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Provide a reference to your default VPC
resource "aws_default_vpc" "default_vpc" {
}

# Provide references to your default subnets
resource "aws_default_subnet" "default_subnet_a" {
  # Use your own region here but reference to subnet 1a
  availability_zone = "us-east-1a"
}

resource "aws_default_subnet" "default_subnet_b" {
  # Use your own region here but reference to subnet 1b
  availability_zone = "us-east-1b"
}

resource "aws_alb" "application_load_balancer" {
  name               = "load-balancer-dev" # Naming our load balancer
  load_balancer_type = "application"
  subnets = [ # Referencing the default subnets
    "${aws_default_subnet.default_subnet_a.id}",
    "${aws_default_subnet.default_subnet_b.id}"
  ]
  # Referencing the security group
  security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
}

# Creating a security group for the load balancer:
resource "aws_security_group" "load_balancer_security_group" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allowing traffic in from all sources
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_default_vpc.default_vpc.id
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.arn
  }
}

resource "aws_ecs_service" "app_service" {
  name            = "app-first-service"                  # Name the  service
  cluster         = aws_ecs_cluster.my_cluster.id        # Reference the created Cluster
  task_definition = aws_ecs_task_definition.app_task.arn # Reference the task that the service will spin up
  launch_type     = "FARGATE"
  desired_count   = 3 # Set up the number of containers to 3

  load_balancer {
    target_group_arn = aws_lb_target_group.target_group.arn # Reference the target group
    container_name   = aws_ecs_task_definition.app_task.family
    container_port   = 5000 # Specify the container port
  }

  network_configuration {
    subnets          = ["${aws_default_subnet.default_subnet_a.id}", "${aws_default_subnet.default_subnet_b.id}"]
    assign_public_ip = true                                                # Provide the containers with public IPs
    security_groups  = ["${aws_security_group.service_security_group.id}"] # Set up the security group
  }
}

resource "aws_security_group" "service_security_group" {
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # Only allowing traffic in from the load balancer security group
    security_groups = ["${aws_security_group.load_balancer_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = var.cloudwatch_group

  tags = {
    Environment = "development"
    Application = "ecs-app"
  }
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log_stream" {
  name           = "ecs-stream"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
}

