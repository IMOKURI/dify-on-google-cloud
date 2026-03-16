variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone (required when availability_type is ZONAL)"
  type        = string
}

variable "availability_type" {
  description = "Availability type: REGIONAL or ZONAL"
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

variable "image_name" {
  description = "Custom VM image name for the MIG boot disk"
  type        = string
  default     = ""
}

variable "startup_script" {
  description = "Startup script content"
  type        = string
}

variable "service_account_email" {
  description = "Service account email"
  type        = string
}

variable "python_requirements" {
  description = "Python requirements.txt content"
  type        = string
  default     = ""
}

variable "sandbox_config" {
  description = "Sandbox configuration file content"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
