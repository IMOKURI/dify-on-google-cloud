# =============================================================================
# Filestore Module - Managed NFS for Dify volumes
# =============================================================================

resource "google_filestore_instance" "dify_filestore" {
  name     = "${var.prefix}-filestore"
  location = var.zone
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
