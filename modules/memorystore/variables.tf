variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone for Redis location"
  type        = string
}

variable "alternative_zone" {
  description = "Alternative GCP Zone for HA configuration (only used with STANDARD_HA tier)"
  type        = string
  default     = null
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "private_vpc_connection_id" {
  description = "Private VPC connection ID (for dependency)"
  type        = string
}

variable "redis_tier" {
  description = "Redis tier (BASIC or STANDARD_HA)"
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.redis_tier)
    error_message = "Redis tier must be either BASIC or STANDARD_HA."
  }
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GB"
  type        = number
}

variable "redis_version" {
  description = "Redis version"
  type        = string
  default     = "REDIS_6_X"
}

variable "redis_reserved_ip_range" {
  description = "CIDR range for Redis reserved IP (optional)"
  type        = string
  default     = null
}

variable "redis_configs" {
  description = "Redis configuration parameters"
  type        = map(string)
  default     = {}
}

variable "auth_enabled" {
  description = "Enable Redis AUTH (password authentication)"
  type        = bool
  default     = true
}

variable "maintenance_policy_enabled" {
  description = "Enable maintenance policy"
  type        = bool
  default     = true
}

variable "maintenance_day" {
  description = "Day of week for maintenance (e.g., MONDAY, TUESDAY, etc.)"
  type        = string
  default     = "SATURDAY"

  validation {
    condition     = contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.maintenance_day)
    error_message = "Maintenance day must be a valid day of the week."
  }
}

variable "maintenance_start_hour" {
  description = "Hour to start maintenance (0-23)"
  type        = number
  default     = 2

  validation {
    condition     = var.maintenance_start_hour >= 0 && var.maintenance_start_hour <= 23
    error_message = "Maintenance start hour must be between 0 and 23."
  }
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
