variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
}

variable "machine_type" {
  description = "Machine type for the VM instance"
  type        = string
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
}

variable "startup_script" {
  description = "Startup script content"
  type        = string
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
}

variable "health_check_id" {
  description = "Health check ID"
  type        = string
}
