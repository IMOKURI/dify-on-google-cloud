# =============================================================================
# Compute Instance Configuration
# =============================================================================

variable "machine_type" {
  description = "Machine type for the VM instance"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.disk_size_gb >= 10 && var.disk_size_gb <= 65536
    error_message = "Disk size must be between 10 and 65536 GB."
  }
}

variable "ssh_user" {
  description = "SSH user name"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key for instance access"
  type        = string
  default     = ""
}

variable "ssh_private_key" {
  description = "SSH private key for instance provisioning (required for file provisioner)"
  type        = string
  default     = ""
  sensitive   = true
}

# =============================================================================
# Auto Scaling Configuration
# =============================================================================

variable "autoscaling_enabled" {
  description = "Enable auto scaling for VM instances"
  type        = bool
  default     = false
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of VM instances"
  type        = number
  default     = 1

  validation {
    condition     = var.autoscaling_min_replicas >= 1
    error_message = "Minimum replicas must be at least 1."
  }
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of VM instances"
  type        = number
  default     = 4

  validation {
    condition     = var.autoscaling_max_replicas >= var.autoscaling_min_replicas
    error_message = "Maximum replicas must be greater than or equal to minimum replicas."
  }
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for autoscaling (0.0-1.0)"
  type        = number
  default     = 0.7

  validation {
    condition     = var.autoscaling_cpu_target > 0 && var.autoscaling_cpu_target <= 1.0
    error_message = "CPU target must be between 0 and 1.0."
  }
}

variable "autoscaling_cooldown_period" {
  description = "Cooldown period in seconds between scaling events"
  type        = number
  default     = 60

  validation {
    condition     = var.autoscaling_cooldown_period >= 60
    error_message = "Cooldown period must be at least 60 seconds."
  }
}

variable "autoscaling_scale_in_max_replicas" {
  description = "Maximum number of instances to remove in a single scale-in event"
  type        = number
  default     = 3

  validation {
    condition     = var.autoscaling_scale_in_max_replicas >= 1
    error_message = "Scale-in max replicas must be at least 1."
  }
}

variable "autoscaling_scale_in_time_window" {
  description = "Time window in seconds for calculating scale-in decisions"
  type        = number
  default     = 120

  validation {
    condition     = var.autoscaling_scale_in_time_window >= 60
    error_message = "Scale-in time window must be at least 60 seconds."
  }
}

variable "autoscaling_custom_metrics" {
  description = "Custom metrics for autoscaling"
  type = list(object({
    name   = string
    target = number
    type   = string # GAUGE, DELTA_PER_SECOND, DELTA_PER_MINUTE
  }))
  default = []
}
