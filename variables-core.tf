# =============================================================================
# Core Project Configuration
# =============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-northeast1-a"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "dify"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.prefix))
    error_message = "Prefix must start with a letter, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {
    managed_by  = "terraform"
    solution    = "dify-on-gcp"
    application = "dify"
  }

  validation {
    condition     = alltrue([for k, v in var.labels : length(k) <= 63 && length(v) <= 63])
    error_message = "All label keys and values must be 63 characters or less."
  }
}
