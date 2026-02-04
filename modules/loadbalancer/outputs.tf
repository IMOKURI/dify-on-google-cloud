output "health_check_id" {
  description = "Health check ID"
  value       = google_compute_health_check.dify_health_check.id
}

output "backend_service_id" {
  description = "Backend service ID"
  value       = google_compute_backend_service.dify_backend.id
}

output "url_map_id" {
  description = "URL map ID"
  value       = google_compute_url_map.dify_url_map.id
}

output "forwarding_rule_ip" {
  description = "Forwarding rule IP address"
  value       = google_compute_global_forwarding_rule.dify_https_forwarding_rule.ip_address
}
