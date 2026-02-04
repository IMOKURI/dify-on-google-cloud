variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "private_vpc_connection_id" {
  description = "Private VPC connection ID (for dependency)"
  type        = string
}

variable "tier" {
  description = "Redis service tier (BASIC or STANDARD_HA)"
  type        = string
}

variable "memory_size_gb" {
  description = "Redis memory size in GiB"
  type        = number
}

variable "redis_version" {
  description = "Redis version"
  type        = string
}

variable "replica_count" {
  description = "Number of read replicas"
  type        = number
}

variable "auth_enabled" {
  description = "Enable Redis AUTH"
  type        = bool
}

variable "transit_encryption_mode" {
  description = "Transit encryption mode"
  type        = string
}

variable "persistence_mode" {
  description = "Persistence mode (DISABLED or RDB)"
  type        = string
}

variable "rdb_snapshot_period" {
  description = "Snapshot period for RDB persistence"
  type        = string
}

variable "rdb_snapshot_start_time" {
  description = "Start time for RDB snapshots"
  type        = string
}

variable "maintenance_window_day" {
  description = "Maintenance window day"
  type        = string
}

variable "maintenance_window_hour" {
  description = "Maintenance window start hour"
  type        = number
}

variable "connect_mode" {
  description = "Connection mode"
  type        = string
}

variable "reserved_ip_range" {
  description = "CIDR range for Redis instance"
  type        = string
}

variable "labels" {
  description = "Labels to apply to the Redis instance"
  type        = map(string)
}
