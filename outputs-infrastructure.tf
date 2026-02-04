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
# Compute Instance Outputs
# =============================================================================

output "instance_group_manager_name" {
  description = "Managed Instance Group name"
  value       = module.compute.instance_group_id
}

output "instance_group_manager_region" {
  description = "Managed Instance Group region"
  value       = var.region
}

output "autoscaling_enabled" {
  description = "Whether autoscaling is enabled"
  value       = var.autoscaling_enabled
}

output "autoscaling_min_replicas" {
  description = "Minimum number of instances"
  value       = var.autoscaling_min_replicas
}

output "autoscaling_max_replicas" {
  description = "Maximum number of instances (if autoscaling enabled)"
  value       = var.autoscaling_enabled ? var.autoscaling_max_replicas : null
}
