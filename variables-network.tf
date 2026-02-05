# =============================================================================
# Network Configuration
# =============================================================================

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR notation."
  }
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH to the instance"
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "domain_name" {
  description = "Domain name for SSL certificate (leave empty to use self-signed certificate)"
  type        = string
  default     = ""
}

variable "ssl_certificate" {
  description = "Self-signed SSL certificate (PEM format, required if domain_name is empty)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssl_private_key" {
  description = "Self-signed SSL private key (PEM format, required if domain_name is empty)"
  type        = string
  default     = ""
  sensitive   = true
}
