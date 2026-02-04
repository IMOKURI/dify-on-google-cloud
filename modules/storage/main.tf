# =============================================================================
# Storage Module - Google Cloud Storage Bucket
# =============================================================================

# GCS Bucket for file storage
resource "google_storage_bucket" "dify_storage" {
  name          = var.bucket_name != "" ? var.bucket_name : "${var.project_id}-${var.prefix}-storage"
  location      = var.location
  force_destroy = var.force_destroy
  storage_class = var.storage_class

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  dynamic "cors" {
    for_each = var.cors_enabled ? [1] : []
    content {
      origin          = var.cors_origins
      method          = var.cors_methods
      response_header = var.cors_response_headers
      max_age_seconds = var.cors_max_age_seconds
    }
  }

  labels = var.labels
}

# GCS Bucket for file storage
resource "google_storage_bucket" "dify_plugin_storage" {
  name          = var.bucket_name != "" ? "${var.bucket_name}-plugin" : "${var.project_id}-${var.prefix}-plugin-storage"
  location      = var.location
  force_destroy = var.force_destroy
  storage_class = var.storage_class

  uniform_bucket_level_access = true

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  dynamic "cors" {
    for_each = var.cors_enabled ? [1] : []
    content {
      origin          = var.cors_origins
      method          = var.cors_methods
      response_header = var.cors_response_headers
      max_age_seconds = var.cors_max_age_seconds
    }
  }

  labels = var.labels
}
