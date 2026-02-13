# =============================================================================
# Filestore Module - Managed NFS for Dify volumes
# =============================================================================

resource "google_filestore_instance" "dify_filestore" {
  name     = "${var.prefix}-filestore"
  location = var.location
  tier     = var.filestore_tier

  file_shares {
    capacity_gb = var.filestore_capacity_gb
    name        = var.filestore_share_name
  }

  networks {
    network = var.network_name
    modes   = ["MODE_IPV4"]
  }

  labels = var.labels
}

# =============================================================================
# Filestore Backup - Optional backup configuration
# =============================================================================

resource "google_filestore_backup" "dify_filestore_backup" {
  count = var.enable_backup ? 1 : 0

  name     = "${var.prefix}-filestore-backup"
  location = var.backup_location != "" ? var.backup_location : var.location
  
  source_instance   = google_filestore_instance.dify_filestore.id
  source_file_share = var.filestore_share_name

  description = "Backup for ${var.prefix} Dify Filestore instance"
  labels      = merge(var.labels, var.backup_labels)
}
