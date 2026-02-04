variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-northeast1"
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "asia-northeast1-a"
}

variable "prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "dify"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "machine_type" {
  description = "Machine type for the VM instance"
  type        = string
  default     = "n1-standard-2"
}

variable "disk_size_gb" {
  description = "Boot disk size in GB"
  type        = number
  default     = 50
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH to the instance"
  type        = list(string)
  default     = ["0.0.0.0/0"] # 本番環境では制限することを推奨
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

variable "docker_compose_version" {
  description = "Docker Compose version to install"
  type        = string
  default     = "v2.24.5"
}

variable "dify_version" {
  description = "Dify version to download and deploy"
  type        = string
  default     = "1.11.4"
}

# Cloud SQL Variables
variable "cloudsql_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-custom-2-7680" # 2 vCPU, 7.5GB RAM
}

variable "cloudsql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 50
}

variable "cloudsql_database_version" {
  description = "PostgreSQL version for Cloud SQL"
  type        = string
  default     = "POSTGRES_15"
}

variable "cloudsql_backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "cloudsql_backup_start_time" {
  description = "Backup start time (HH:MM format)"
  type        = string
  default     = "03:00"
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "dify"
}

variable "db_user" {
  description = "Database user name"
  type        = string
  default     = "dify"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

variable "create_service_account_key" {
  description = "Create service account key for external use (not needed if running on GCE VM)"
  type        = bool
  default     = false
}

# =============================================================================
# pgvector Configuration
# =============================================================================

variable "pgvector_database_version" {
  description = "PostgreSQL version for pgvector Cloud SQL instance (must be 11 or higher for vector support)"
  type        = string
  default     = "POSTGRES_16"
}

variable "pgvector_tier" {
  description = "Cloud SQL instance tier for pgvector instance"
  type        = string
  default     = "db-custom-4-16384" # 4 vCPU, 16GB RAM - recommended for vector operations
}

variable "pgvector_disk_size" {
  description = "Cloud SQL disk size in GB for pgvector instance"
  type        = number
  default     = 100
}

variable "pgvector_availability_type" {
  description = "Availability type for pgvector instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"
}

variable "pgvector_deletion_protection" {
  description = "Enable deletion protection for pgvector instance"
  type        = bool
  default     = true
}

variable "pgvector_backup_enabled" {
  description = "Enable automated backups for pgvector instance"
  type        = bool
  default     = true
}

variable "pgvector_backup_start_time" {
  description = "Backup start time for pgvector instance (HH:MM format)"
  type        = string
  default     = "04:00"
}

variable "pgvector_backup_retention_count" {
  description = "Number of backups to retain for pgvector instance"
  type        = number
  default     = 7
}

variable "pgvector_db_name" {
  description = "Database name for pgvector"
  type        = string
  default     = "dify_vector"
}

variable "pgvector_db_user" {
  description = "Database user name for pgvector"
  type        = string
  default     = "dify_vector"
}

variable "pgvector_db_password" {
  description = "Database password for pgvector (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "pgvector_enable_public_ip" {
  description = "Enable public IP for pgvector instance (not recommended for production)"
  type        = bool
  default     = false
}

variable "pgvector_authorized_networks" {
  description = "Authorized networks for pgvector instance (only used if public IP is enabled)"
  type = list(object({
    name = string
    cidr = string
  }))
  default = []
}

# Performance tuning variables
# Note: Cloud SQL auto-manages memory settings based on instance tier
variable "pgvector_max_connections" {
  description = "Maximum number of connections for pgvector instance"
  type        = string
  default     = "200"
}

# The following memory settings are automatically managed by Cloud SQL
# based on the instance tier. They cannot be manually configured.
# - shared_buffers (auto-configured ~25% of RAM)
# - effective_cache_size (auto-configured ~75% of RAM)
# - maintenance_work_mem (auto-configured for index creation)
# - work_mem (auto-configured for query operations)

variable "pgvector_query_insights_enabled" {
  description = "Enable Query Insights for pgvector instance"
  type        = bool
  default     = true
}

variable "pgvector_maintenance_window_day" {
  description = "Maintenance window day (1-7, 1=Monday, 7=Sunday)"
  type        = number
  default     = 6 # Saturday
}

variable "pgvector_maintenance_window_hour" {
  description = "Maintenance window hour (0-23)"
  type        = number
  default     = 4
}

# Read replica configuration
variable "pgvector_enable_read_replica" {
  description = "Enable read replica for pgvector instance"
  type        = bool
  default     = false
}

variable "pgvector_replica_region" {
  description = "Region for read replica (leave empty to use same region as primary)"
  type        = string
  default     = ""
}

variable "pgvector_replica_tier" {
  description = "Machine type for read replica (leave empty to use same as primary)"
  type        = string
  default     = ""
}

# =============================================================================
# Google Cloud Storage Configuration
# =============================================================================

variable "gcs_bucket_name" {
  description = "Name of the GCS bucket for file storage (leave empty to auto-generate)"
  type        = string
  default     = ""
}

variable "gcs_location" {
  description = "Location for the GCS bucket"
  type        = string
  default     = "ASIA-NORTHEAST1"
}

variable "gcs_storage_class" {
  description = "Storage class for the GCS bucket (STANDARD, NEARLINE, COLDLINE, ARCHIVE)"
  type        = string
  default     = "STANDARD"
}

variable "gcs_versioning_enabled" {
  description = "Enable versioning for the GCS bucket"
  type        = bool
  default     = false
}

variable "gcs_force_destroy" {
  description = "Allow bucket to be destroyed even if it contains objects (not recommended for production)"
  type        = bool
  default     = false
}

variable "gcs_lifecycle_rules" {
  description = "Lifecycle rules for the GCS bucket"
  type = list(object({
    action = object({
      type          = string
      storage_class = optional(string)
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      with_state            = optional(string)
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
}

variable "gcs_cors_enabled" {
  description = "Enable CORS configuration for the GCS bucket"
  type        = bool
  default     = true
}

variable "gcs_cors_origins" {
  description = "Allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "gcs_cors_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "HEAD", "PUT", "POST", "DELETE"]
}

variable "gcs_cors_response_headers" {
  description = "Allowed response headers for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "gcs_cors_max_age_seconds" {
  description = "Max age for CORS preflight requests in seconds"
  type        = number
  default     = 3600
}

variable "gcs_labels" {
  description = "Labels to apply to the GCS bucket"
  type        = map(string)
  default     = {}
}

# =============================================================================
# Redis Memorystore Configuration
# =============================================================================

variable "redis_tier" {
  description = "Redis service tier (BASIC for standalone, STANDARD_HA for high availability)"
  type        = string
  default     = "STANDARD_HA"
  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.redis_tier)
    error_message = "Redis tier must be either BASIC or STANDARD_HA."
  }
}

variable "redis_memory_size_gb" {
  description = "Redis memory size in GiB (minimum 1 for BASIC, 5 for STANDARD_HA)"
  type        = number
  default     = 5
}

variable "redis_version" {
  description = "Redis version (REDIS_6_X, REDIS_7_0, REDIS_7_2)"
  type        = string
  default     = "REDIS_7_2"
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
  default     = "TWELVE_HOURS"
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

# =============================================================================
# Auto Scaling Configuration
# =============================================================================

variable "autoscaling_enabled" {
  description = "Enable auto scaling for VM instances"
  type        = bool
  default     = true
}

variable "autoscaling_min_replicas" {
  description = "Minimum number of VM instances"
  type        = number
  default     = 2
}

variable "autoscaling_max_replicas" {
  description = "Maximum number of VM instances"
  type        = number
  default     = 10
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
}

variable "autoscaling_scale_in_max_replicas" {
  description = "Maximum number of instances to remove in a single scale-in event"
  type        = number
  default     = 3
}

variable "autoscaling_scale_in_time_window" {
  description = "Time window in seconds for calculating scale-in decisions"
  type        = number
  default     = 120
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
