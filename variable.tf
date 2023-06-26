variable "cloudwatch_group" {
  description = "CloudWatch group name."
  type        = string
  default     = "ecs-log-group"
}

variable "aws_region" {
  description = "AWS Region to deploy to"
  type        = string
  default     = "us-west-1"
}
