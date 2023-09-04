
resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name = var.cloudwatch_group_name

  tags = {
    Environment = "development"
    Application = "ecs-app"
  }
}

resource "aws_cloudwatch_log_stream" "cloudwatch_log_stream" {
  name           = "ecs-stream"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
}
