# =============================================================================
# Google Cloud Storage Configuration
# =============================================================================

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket for file storage (leave empty to auto-generate)"
  type        = string
  default     = ""
}

variable "gcs_location" {
  description = "Location for the GCS bucket"
  type        = string
  default     = "ASIA-NORTHEAST1"
}

variable "gcs_storage_class" {
  description = "Storage class for the GCS bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "NEARLINE", "COLDLINE", "ARCHIVE"], var.gcs_storage_class)
    error_message = "Storage class must be one of: STANDARD, NEARLINE, COLDLINE, ARCHIVE."
  }
}

variable "gcs_versioning_enabled" {
  description = "Enable versioning for the GCS bucket"
  type        = bool
  default     = false
}

variable "gcs_force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects (not recommended for production)"
  type        = bool
  default     = false
}

variable "gcs_lifecycle_rules" {
  description = "Lifecycle rules for the GCS bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state            = optional(string)
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
}

variable "gcs_cors_enabled" {
  description = "Enable CORS configuration for the GCS bucket"
  type        = bool
  default     = true
}

variable "gcs_cors_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "gcs_cors_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "HEAD", "PUT", "POST", "DELETE"]
}

variable "gcs_cors_response_headers" {
  description = "Allowed response headers for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "gcs_cors_max_age_seconds" {
  description = "Max age for CORS preflight requests in seconds"
  type        = number
  default     = 3600

  validation {
    condition     = var.gcs_cors_max_age_seconds >= 0 && var.gcs_cors_max_age_seconds <= 86400
    error_message = "CORS max age must be between 0 and 86400 seconds (24 hours)."
  }
}
