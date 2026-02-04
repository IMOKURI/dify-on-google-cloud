variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "storage_bucket_name" {
  description = "Name of the GCS bucket for IAM permissions"
  type        = string
}

variable "create_service_account_key" {
  description = "Whether to create a service account key"
  type        = bool
  default     = false
}
