# =============================================================================
# Google Cloud Storage Outputs
# =============================================================================

output "gcs_bucket_name" {
  description = "Name of the GCS bucket"
  value       = module.storage.bucket_name
}

output "gcs_bucket_url" {
  description = "URL of the GCS bucket"
  value       = module.storage.bucket_url
}

output "gcs_bucket_self_link" {
  description = "Self link of the GCS bucket"
  value       = module.storage.bucket_self_link
}

output "service_account_email" {
  description = "Email of the Dify service account"
  value       = module.iam.service_account_email
}

output "google_storage_service_account_json_base64" {
  description = "Base64-encoded service account JSON key for Google Storage access (only if create_service_account_key is true)"
  value       = var.create_service_account_key ? module.iam.service_account_key : "Not created - VM uses default service account"
  sensitive   = true
}
