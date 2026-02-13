# =============================================================================
# Filestore Module Outputs
# =============================================================================

output "filestore_ip" {
  description = "IP address of the Filestore instance"
  value       = google_filestore_instance.dify_filestore.networks[0].ip_addresses[0]
}

output "filestore_instance_id" {
  description = "Full resource ID of the Filestore instance"
  value       = google_filestore_instance.dify_filestore.id
}

output "filestore_share_name" {
  description = "Name of the Filestore share"
  value       = google_filestore_instance.dify_filestore.file_shares[0].name
}

output "filestore_mount_point" {
  description = "Mount point path for the Filestore share"
  value       = "${google_filestore_instance.dify_filestore.networks[0].ip_addresses[0]}:/${google_filestore_instance.dify_filestore.file_shares[0].name}"
}

output "backup_id" {
  description = "ID of the Filestore backup (if enabled)"
  value       = var.enable_backup ? google_filestore_backup.dify_filestore_backup[0].id : null
}

output "backup_name" {
  description = "Name of the Filestore backup (if enabled)"
  value       = var.enable_backup ? google_filestore_backup.dify_filestore_backup[0].name : null
}
