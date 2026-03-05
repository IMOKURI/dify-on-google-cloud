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

variable "iap_members" {
  description = "List of principals to grant the IAP-secured Tunnel User role for SSH via Cloud IAP"
  type        = list(string)
  default     = []
}
