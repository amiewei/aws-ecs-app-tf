output "alb_dns_name" {
  value = aws_alb.application_load_balancer.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.target_group.arn
}

output "service_security_group_id" {
  value = aws_security_group.service_security_group.id
}

output "default_subnet_a_id" {
  value = aws_default_subnet.default_subnet_a.id
}

output "default_subnet_c_id" {
  value = aws_default_subnet.default_subnet_c.id
}
