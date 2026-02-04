# =============================================================================
# Redis Memorystore Configuration
# =============================================================================

variable "redis_tier" {
  description = "Redis service tier (BASIC for standalone, STANDARD_HA for high availability)"
  type        = string
  default     = "BASIC"

  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.redis_tier)
    error_message = "Redis tier must be either BASIC or STANDARD_HA."
  }
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GiB (minimum 1 for BASIC, 5 for STANDARD_HA)"
  type        = number
  default     = 5

  validation {
    condition     = var.redis_memory_size_gb >= 1 && var.redis_memory_size_gb <= 300
    error_message = "Redis memory size must be between 1 and 300 GiB."
  }
}

variable "redis_version" {
  description = "Redis version (REDIS_6_X, REDIS_7_0, REDIS_7_2)"
  type        = string
  default     = "REDIS_7_2"

  validation {
    condition     = contains(["REDIS_6_X", "REDIS_7_0", "REDIS_7_2"], var.redis_version)
    error_message = "Redis version must be one of: REDIS_6_X, REDIS_7_0, REDIS_7_2."
  }
}

variable "redis_replica_count" {
  description = "Number of read replicas (0-5, only for STANDARD_HA tier)"
  type        = number
  default     = 1

  validation {
    condition     = var.redis_replica_count >= 0 && var.redis_replica_count <= 5
    error_message = "Redis replica count must be between 0 and 5."
  }
}

variable "redis_auth_enabled" {
  description = "Enable Redis AUTH (authentication)"
  type        = bool
  default     = true
}

variable "redis_transit_encryption_mode" {
  description = "Transit encryption mode (DISABLED or SERVER_AUTHENTICATION)"
  type        = string
  default     = "DISABLED"

  validation {
    condition     = contains(["DISABLED", "SERVER_AUTHENTICATION"], var.redis_transit_encryption_mode)
    error_message = "Transit encryption mode must be either DISABLED or SERVER_AUTHENTICATION."
  }
}

variable "redis_persistence_mode" {
  description = "Persistence mode (DISABLED or RDB - only for STANDARD_HA tier)"
  type        = string
  default     = "RDB"

  validation {
    condition     = contains(["DISABLED", "RDB"], var.redis_persistence_mode)
    error_message = "Persistence mode must be either DISABLED or RDB."
  }
}

variable "redis_rdb_snapshot_period" {
  description = "Snapshot period for RDB persistence (ONE_HOUR, SIX_HOURS, TWELVE_HOURS, TWENTY_FOUR_HOURS)"
  type        = string
  default     = "TWENTY_FOUR_HOURS"

  validation {
    condition     = contains(["ONE_HOUR", "SIX_HOURS", "TWELVE_HOURS", "TWENTY_FOUR_HOURS"], var.redis_rdb_snapshot_period)
    error_message = "RDB snapshot period must be one of: ONE_HOUR, SIX_HOURS, TWELVE_HOURS, TWENTY_FOUR_HOURS."
  }
}

variable "redis_rdb_snapshot_start_time" {
  description = "Start time for RDB snapshots in RFC3339 format (e.g., 2024-01-01T03:00:00Z)"
  type        = string
  default     = ""
}

variable "redis_maintenance_window_day" {
  description = "Maintenance window day (MONDAY-SUNDAY)"
  type        = string
  default     = "SUNDAY"

  validation {
    condition     = contains(["MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY", "SUNDAY"], var.redis_maintenance_window_day)
    error_message = "Maintenance window day must be a valid day of the week (MONDAY-SUNDAY)."
  }
}

variable "redis_maintenance_window_hour" {
  description = "Maintenance window start hour (0-23)"
  type        = number
  default     = 3

  validation {
    condition     = var.redis_maintenance_window_hour >= 0 && var.redis_maintenance_window_hour <= 23
    error_message = "Maintenance window hour must be between 0 and 23."
  }
}

variable "redis_connect_mode" {
  description = "Connection mode (DIRECT_PEERING or PRIVATE_SERVICE_ACCESS)"
  type        = string
  default     = "DIRECT_PEERING"

  validation {
    condition     = contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.redis_connect_mode)
    error_message = "Connect mode must be either DIRECT_PEERING or PRIVATE_SERVICE_ACCESS."
  }
}

variable "redis_reserved_ip_range" {
  description = "CIDR range for Redis instance (must be /29, e.g., 10.0.2.0/29). Leave empty for auto-assignment."
  type        = string
  default     = ""
}

variable "redis_labels" {
  description = "Labels to apply to the Redis instance"
  type        = map(string)
  default     = {}
}
