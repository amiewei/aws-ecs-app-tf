variable "aws_region" {}
variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
}

variable "private_subnets" {
  description = "List of private subnets"
  type        = list(string)
}

variable "ecs_cluster_name" {
  description = "ECS cluster name"
  type        = string
}

variable "ecs_cluster_arn" {
  description = "ECS cluster ARN"
  type        = string
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN"
  type        = string
}

variable "service_discovery_namespaces" {
  description = "service discovery namespace id"
  type        = any
}

variable "private_subnets_cidr_blocks" {
  description = "private_subnets_cidr_blocks"
  type        = list(any)
}

variable "container_image" {
  description = "The container image for the ECS service."
  type        = string
}

variable "container_port" {
  description = "The port for the container."
  type        = number
  default     = 5000
}
