variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "health_check_id" {
  description = "Health check ID from compute module"
  type        = string
}

variable "instance_group" {
  description = "Managed instance group URL"
  type        = string
}

variable "lb_ip_address" {
  description = "Load balancer IP address"
  type        = string
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
}

variable "ssl_certificate" {
  description = "Self-signed SSL certificate (PEM format)"
  type        = string
  sensitive   = true
}

variable "ssl_private_key" {
  description = "Self-signed SSL private key (PEM format)"
  type        = string
  sensitive   = true
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "iap_enabled" {
  description = "Enable Identity-Aware Proxy"
  type        = bool
  default     = false
}

variable "iap_oauth_client_id" {
  description = "OAuth 2.0 client ID for IAP"
  type        = string
  default     = ""
  sensitive   = true
}

variable "iap_oauth_client_secret" {
  description = "OAuth 2.0 client secret for IAP"
  type        = string
  default     = ""
  sensitive   = true
}

variable "iap_members" {
  description = "List of IAM members allowed to access through IAP"
  type        = list(string)
  default     = []
}

variable "project_id" {
  description = "GCP Project ID for IAP IAM bindings"
  type        = string
  default     = ""
}
