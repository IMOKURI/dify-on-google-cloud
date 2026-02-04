variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket (leave empty to auto-generate)"
  type        = string
  default     = ""
}

variable "location" {
  description = "Location for the GCS bucket"
  type        = string
}

variable "storage_class" {
  description = "Storage class for the GCS bucket"
  type        = string
}

variable "versioning_enabled" {
  description = "Enable versioning for the GCS bucket"
  type        = bool
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects"
  type        = bool
}

variable "lifecycle_rules" {
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
}

variable "cors_enabled" {
  description = "Enable CORS configuration for the GCS bucket"
  type        = bool
}

variable "cors_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
}

variable "cors_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
}

variable "cors_response_headers" {
  description = "Allowed response headers for CORS"
  type        = list(string)
}

variable "cors_max_age_seconds" {
  description = "Max age for CORS preflight requests in seconds"
  type        = number
}

variable "labels" {
  description = "Labels to apply to the GCS bucket"
  type        = map(string)
}
