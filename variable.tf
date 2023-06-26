variable "cloudwatch_group" {
  description = "CloudWatch group name."
  type        = string
  default     = "ecs-log-group"
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
