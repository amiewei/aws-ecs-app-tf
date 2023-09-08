output "application_url" {
  value       = module.lb_service.application_url
  description = "Copy this value in your browser in order to access the deployed app"
}
