variable "cloudwatch_group_name" {
  description = "CloudWatch group name"
  type        = string
  default     = "ecs-cloudwatch-log-group"
}

variable "aws_region" {
  description = "AWS Region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "ecs_task_count" {
  description = "Number of desired ECS tasks"
  type        = number
  default     = 3
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "ecs_cluster_tfc"
}
