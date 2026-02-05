output "service_account_email" {
  description = "Email address of the service account"
  value       = google_service_account.dify_sa.email
}

output "service_account_name" {
  description = "Name of the service account"
  value       = google_service_account.dify_sa.name
}

output "service_account_key" {
  description = "Service account key (if created)"
  value       = google_service_account_key.dify_sa_key[0].private_key
  sensitive   = true
}
