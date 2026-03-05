# =============================================================================
# IAM Module - Service Account and IAM Permissions
# =============================================================================

# Service Account for VM
resource "google_service_account" "dify_sa" {
  account_id   = "${var.prefix}-sa"
  display_name = "Dify Service Account"
}

# IAM binding for service account
resource "google_project_iam_member" "dify_sa_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.dify_sa.email}"

  depends_on = [
    google_service_account.dify_sa
  ]
}

resource "google_project_iam_member" "dify_sa_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.dify_sa.email}"

  depends_on = [
    google_service_account.dify_sa
  ]
}

# IAP Tunnel User role - allows SSH to VM instances via Cloud IAP
resource "google_project_iam_member" "iap_tunnel_user" {
  for_each = toset(var.iap_members)

  project = var.project_id
  role    = "roles/iap.tunnelResourceAccessor"
  member  = each.value
}
