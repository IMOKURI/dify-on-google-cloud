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
}

resource "google_project_iam_member" "dify_sa_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.dify_sa.email}"
}

resource "google_project_iam_member" "dify_sa_storage_viewer" {
  project = var.project_id
  role    = "roles/storage.bucketViewer"
  member  = "serviceAccount:${google_service_account.dify_sa.email}"
}

# Grant bucket-level permissions
resource "google_storage_bucket_iam_member" "dify_storage_object_admin" {
  bucket = var.storage_bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.dify_sa.email}"
}

# Service Account Key for GCS access (optional, only if needed outside GCE)
resource "google_service_account_key" "dify_sa_key" {
  count              = var.create_service_account_key ? 1 : 0
  service_account_id = google_service_account.dify_sa.name
}
