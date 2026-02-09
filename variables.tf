# =============================================================================
# Core Project Configuration
# =============================================================================

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

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.prefix))
    error_message = "Prefix must start with a letter, contain only lowercase letters, numbers, and hyphens, and be 1-63 characters long."
  }
}

variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default = {
    managed_by  = "terraform"
    solution    = "dify-on-gcp"
    application = "dify"
  }

  validation {
    condition     = alltrue([for k, v in var.labels : length(k) <= 63 && length(v) <= 63])
    error_message = "All label keys and values must be 63 characters or less."
  }
}

# =============================================================================
# Network Configuration
# =============================================================================

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.1.0/24"

  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "Subnet CIDR must be a valid IPv4 CIDR notation."
  }
}

variable "ssh_source_ranges" {
  description = "CIDR ranges allowed to SSH to the instance"
  type        = list(string)
  default     = ["35.235.240.0/20"]
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

# =============================================================================
# Compute Instance Configuration
# =============================================================================

variable "machine_type" {
  description = "Machine type for the VM instance"
  type        = string
  default     = "e2-standard-8"
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
  default     = "REGIONAL"

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
  default     = ""
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
    condition     = can(regex("^POSTGRES_(1[1-9]|[2-9][0-9])$", var.pgvector_database_version))
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
  default     = "REGIONAL"

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

# =============================================================================
# Filestore Configuration Variables
# =============================================================================

variable "filestore_tier" {
  description = "Filestore service tier (BASIC_HDD, BASIC_SSD, HIGH_SCALE_SSD, or ENTERPRISE)"
  type        = string
  default     = "BASIC_HDD"
}

variable "filestore_capacity_gb" {
  description = "Filestore capacity in GB (minimum 1024 GB for BASIC_HDD, 2560 GB for BASIC_SSD)"
  type        = number
  default     = 1024
}

variable "filestore_share_name" {
  description = "Name of the Filestore share"
  type        = string
  default     = "dify_volumes"
}

# =============================================================================
# Application Configuration
# =============================================================================

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
