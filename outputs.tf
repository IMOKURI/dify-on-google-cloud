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

# =============================================================================
# Application Outputs
# =============================================================================

output "initial_password" {
  description = "Dify initial password"
  value       = random_password.initial_password.result
  sensitive   = true
}

output "dify_version" {
  description = "Deployed Dify version"
  value       = var.dify_version
}

# =============================================================================
# Backup Scheduler Outputs
# =============================================================================

output "backup_scheduler_job_name" {
  description = "Name of the Cloud Scheduler job for automated backups"
  value       = module.backup_scheduler.scheduler_job_name
}

output "backup_function_name" {
  description = "Name of the Cloud Function for creating backups"
  value       = module.backup_scheduler.function_name
}
