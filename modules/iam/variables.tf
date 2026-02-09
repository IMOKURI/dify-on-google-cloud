variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
