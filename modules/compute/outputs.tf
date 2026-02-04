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
  value       = google_compute_region_instance_group_manager.dify_mig.id
}

output "instance_group" {
  description = "Managed instance group URL"
  value       = google_compute_region_instance_group_manager.dify_mig.instance_group
}
