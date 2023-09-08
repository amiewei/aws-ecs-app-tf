variable "aws_region" {
  type = string
}

variable "num_az" {
  description = "Number of AZs"
  type        = number
  default     = 3
}
