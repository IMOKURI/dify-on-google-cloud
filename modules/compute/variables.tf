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

variable "autoscaling_enabled" {
  description = "Enable auto scaling"
  type        = bool
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of VM instances"
  type        = number
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of VM instances"
  type        = number
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization for autoscaling"
  type        = number
}

variable "autoscaling_cooldown_period" {
  description = "Cooldown period in seconds between scaling events"
  type        = number
}

variable "autoscaling_scale_in_max_replicas" {
  description = "Maximum number of instances to remove in scale-in"
  type        = number
}

variable "autoscaling_scale_in_time_window" {
  description = "Time window for scale-in decisions"
  type        = number
}

variable "autoscaling_custom_metrics" {
  description = "Custom metrics for autoscaling"
  type = list(object({
    name   = string
    target = number
    type   = string
  }))
}
