output "service_account_email" {
  description = "Email address of the service account"
  value       = google_service_account.dify_sa.email
}

output "service_account_name" {
  description = "Name of the service account"
  value       = google_service_account.dify_sa.name
}
