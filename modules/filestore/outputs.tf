# =============================================================================
# Filestore Module Outputs
# =============================================================================

output "filestore_ip" {
  description = "IP address of the Filestore instance"
  value       = google_filestore_instance.dify_filestore.networks[0].ip_addresses[0]
}

output "filestore_share_name" {
  description = "Name of the Filestore share"
  value       = google_filestore_instance.dify_filestore.file_shares[0].name
}

output "filestore_mount_point" {
  description = "Mount point path for the Filestore share"
  value       = "${google_filestore_instance.dify_filestore.networks[0].ip_addresses[0]}:/${google_filestore_instance.dify_filestore.file_shares[0].name}"
}
