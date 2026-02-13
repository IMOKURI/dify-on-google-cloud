# =============================================================================
# Backup Scheduler Module Outputs
# =============================================================================

output "scheduler_job_name" {
  description = "Name of the Cloud Scheduler job"
  value       = var.enable_backup_scheduler ? google_cloud_scheduler_job.backup_schedule[0].name : null
}

output "function_name" {
  description = "Name of the Cloud Function"
  value       = var.enable_backup_scheduler ? google_cloudfunctions2_function.backup_function[0].name : null
}

output "service_account_email" {
  description = "Email of the backup scheduler service account"
  value       = var.enable_backup_scheduler ? google_service_account.backup_scheduler[0].email : null
}
