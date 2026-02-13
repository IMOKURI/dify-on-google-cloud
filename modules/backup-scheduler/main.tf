# =============================================================================
# Backup Scheduler Module - Automated Filestore Backups
# =============================================================================

# Cloud Functions用のサービスアカウント
resource "google_service_account" "backup_scheduler" {
  count = var.enable_backup_scheduler ? 1 : 0

  account_id   = "${var.prefix}-backup-scheduler"
  display_name = "Filestore Backup Scheduler Service Account"
  description  = "Service account for automated Filestore backups"
}

# Filestore Backup作成権限
resource "google_project_iam_member" "backup_creator" {
  count = var.enable_backup_scheduler ? 1 : 0

  project = var.project_id
  role    = "roles/file.editor"
  member  = "serviceAccount:${google_service_account.backup_scheduler[0].email}"
}

# Cloud Storageバケット（Cloud Functionsのソースコード用）
resource "google_storage_bucket" "function_source" {
  count = var.enable_backup_scheduler ? 1 : 0

  name                        = "${var.prefix}-backup-function-source"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  labels = var.labels
}

# Cloud Functionsソースコードのアーカイブ
data "archive_file" "function_source" {
  count = var.enable_backup_scheduler ? 1 : 0

  type        = "zip"
  output_path = "${path.module}/function-source.zip"
  source_dir  = "${path.module}/function"
}

# Cloud Storageにソースコードをアップロード
resource "google_storage_bucket_object" "function_source" {
  count = var.enable_backup_scheduler ? 1 : 0

  name   = "function-source-${data.archive_file.function_source[0].output_md5}.zip"
  bucket = google_storage_bucket.function_source[0].name
  source = data.archive_file.function_source[0].output_path
}

# Cloud Functions (Gen 2)
resource "google_cloudfunctions2_function" "backup_function" {
  count = var.enable_backup_scheduler ? 1 : 0

  name        = "${var.prefix}-filestore-backup"
  location    = var.region
  description = "Automated Filestore backup function"

  build_config {
    runtime     = "python311"
    entry_point = "create_backup"
    source {
      storage_source {
        bucket = google_storage_bucket.function_source[0].name
        object = google_storage_bucket_object.function_source[0].name
      }
    }
  }

  service_config {
    max_instance_count    = 1
    available_memory      = "256M"
    timeout_seconds       = 300
    service_account_email = google_service_account.backup_scheduler[0].email

    environment_variables = {
      PROJECT_ID           = var.project_id
      FILESTORE_INSTANCE   = var.filestore_instance_id
      FILESTORE_LOCATION   = var.filestore_location
      FILESTORE_SHARE_NAME = var.filestore_share_name
      BACKUP_LOCATION      = var.backup_location != "" ? var.backup_location : var.filestore_location
      RETENTION_DAYS       = var.backup_retention_days
    }
  }

  labels = var.labels
}

# Cloud Functions呼び出し権限（Cloud Scheduler用）
resource "google_cloud_run_service_iam_member" "invoker" {
  count = var.enable_backup_scheduler ? 1 : 0

  location = google_cloudfunctions2_function.backup_function[0].location
  service  = google_cloudfunctions2_function.backup_function[0].name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.backup_scheduler[0].email}"
}

# Cloud Scheduler ジョブ
resource "google_cloud_scheduler_job" "backup_schedule" {
  count = var.enable_backup_scheduler ? 1 : 0

  name             = "${var.prefix}-filestore-backup-schedule"
  description      = "Scheduled Filestore backup job"
  schedule         = var.backup_schedule
  time_zone        = var.backup_timezone
  attempt_deadline = "320s"
  region           = var.region

  http_target {
    http_method = "POST"
    uri         = google_cloudfunctions2_function.backup_function[0].service_config[0].uri

    oidc_token {
      service_account_email = google_service_account.backup_scheduler[0].email
    }
  }
}
