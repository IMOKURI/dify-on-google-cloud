# =============================================================================
# Load Balancer & Network Outputs
# =============================================================================

output "load_balancer_ip" {
  description = "Load Balancer IP address"
  value       = module.network.lb_ip_address
}

output "https_url" {
  description = "HTTPS URL to access the application"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${module.network.lb_ip_address}"
}

output "initial_password" {
  description = "Dify initial password"
  value       = random_password.initial_password.result
  sensitive   = true
}
