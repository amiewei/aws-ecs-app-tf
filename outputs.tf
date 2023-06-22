# output "ecr_repo_url" {
#   value = aws_ecr_repository.app_ecr_repo.repository_url
# }

output "app_url" {
  value = aws_alb.application_load_balancer.dns_name
}
