output "instance_template_id" {
  description = "Instance template ID"
  value       = google_compute_instance_template.dify_template.id
}

output "instance_template_self_link" {
  description = "Instance template self link"
  value       = google_compute_instance_template.dify_template.self_link
}

output "instance_group_id" {
  description = "Managed instance group ID"
  value       = var.availability_type == "REGIONAL" ? google_compute_region_instance_group_manager.dify_mig_regional[0].id : google_compute_instance_group_manager.dify_mig_zonal[0].id
}

output "instance_group" {
  description = "Managed instance group URL"
  value       = var.availability_type == "REGIONAL" ? google_compute_region_instance_group_manager.dify_mig_regional[0].instance_group : google_compute_instance_group_manager.dify_mig_zonal[0].instance_group
}

output "health_check_id" {
  description = "Health check ID for load balancer"
  value       = google_compute_health_check.dify_health_check.id
}
