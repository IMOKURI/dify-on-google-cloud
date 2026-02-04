# =============================================================================
# Cloud SQL - Main PostgreSQL Configuration
# =============================================================================

variable "cloudsql_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-custom-4-16384" # 4 vCPU, 16GB RAM
}

variable "cloudsql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 50

  validation {
    condition     = var.cloudsql_disk_size >= 10
    error_message = "Cloud SQL disk size must be at least 10 GB."
  }
}

variable "cloudsql_database_version" {
  description = "PostgreSQL version for Cloud SQL"
  type        = string
  default     = "POSTGRES_15"

  validation {
    condition     = can(regex("^POSTGRES_[0-9]+$", var.cloudsql_database_version))
    error_message = "Database version must be in the format POSTGRES_XX (e.g., POSTGRES_15)."
  }
}

variable "cloudsql_availability_type" {
  description = "Availability type for Cloud SQL instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.cloudsql_availability_type)
    error_message = "Availability type must be either ZONAL or REGIONAL."
  }
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

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.cloudsql_backup_start_time))
    error_message = "Backup start time must be in HH:MM format (e.g., 03:00)."
  }
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

# =============================================================================
# Cloud SQL - pgvector Configuration
# =============================================================================

variable "pgvector_database_version" {
  description = "PostgreSQL version for pgvector Cloud SQL instance (must be 11 or higher for vector support)"
  type        = string
  default     = "POSTGRES_16"

  validation {
    condition     = can(regex("^POSTGRES_([1-9][1-9]|1[1-9])$", var.pgvector_database_version))
    error_message = "pgvector requires PostgreSQL 11 or higher."
  }
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

  validation {
    condition     = var.pgvector_disk_size >= 10
    error_message = "pgvector disk size must be at least 10 GB."
  }
}

variable "pgvector_availability_type" {
  description = "Availability type for pgvector instance (ZONAL or REGIONAL)"
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.pgvector_availability_type)
    error_message = "Availability type must be either ZONAL or REGIONAL."
  }
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

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3]):[0-5][0-9]$", var.pgvector_backup_start_time))
    error_message = "Backup start time must be in HH:MM format (e.g., 04:00)."
  }
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
