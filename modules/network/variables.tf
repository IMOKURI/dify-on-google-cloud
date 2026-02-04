variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH to the instance"
  type        = list(string)
}

variable "redis_reserved_ip_range" {
  description = "Reserved IP range for Redis"
  type        = string
  default     = ""
}
