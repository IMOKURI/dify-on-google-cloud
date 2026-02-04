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

# Main PostgreSQL instance variables
variable "cloudsql_tier" {
  description = "Cloud SQL instance tier"
  type        = string
}

variable "cloudsql_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
}

variable "cloudsql_database_version" {
  description = "PostgreSQL version for Cloud SQL"
  type        = string
}

variable "cloudsql_backup_enabled" {
  description = "Enable automated backups"
  type        = bool
}

variable "cloudsql_backup_start_time" {
  description = "Backup start time (HH:MM format)"
  type        = string
}

variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_user" {
  description = "Database user name"
  type        = string
}

variable "db_password" {
  description = "Database password (leave empty to auto-generate)"
  type        = string
  default     = ""
  sensitive   = true
}

# pgvector instance variables
variable "pgvector_database_version" {
  description = "PostgreSQL version for pgvector Cloud SQL instance"
  type        = string
}

variable "pgvector_tier" {
  description = "Cloud SQL instance tier for pgvector instance"
  type        = string
}

variable "pgvector_disk_size" {
  description = "Cloud SQL disk size in GB for pgvector instance"
  type        = number
}

variable "pgvector_availability_type" {
  description = "Availability type for pgvector instance"
  type        = string
}

variable "pgvector_deletion_protection" {
  description = "Enable deletion protection for pgvector instance"
  type        = bool
}

variable "pgvector_backup_enabled" {
  description = "Enable automated backups for pgvector instance"
  type        = bool
}

variable "pgvector_backup_start_time" {
  description = "Backup start time for pgvector instance"
  type        = string
}

variable "pgvector_backup_retention_count" {
  description = "Number of backups to retain for pgvector instance"
  type        = number
}

variable "pgvector_db_name" {
  description = "Database name for pgvector"
  type        = string
}

variable "pgvector_db_user" {
  description = "Database user name for pgvector"
  type        = string
}

variable "pgvector_db_password" {
  description = "Database password for pgvector"
  type        = string
  default     = ""
  sensitive   = true
}

variable "pgvector_enable_public_ip" {
  description = "Enable public IP for pgvector instance"
  type        = bool
}

variable "pgvector_authorized_networks" {
  description = "Authorized networks for pgvector instance"
  type = list(object({
    name = string
    cidr = string
  }))
}

variable "pgvector_max_connections" {
  description = "Maximum number of connections for pgvector instance"
  type        = string
}

variable "pgvector_query_insights_enabled" {
  description = "Enable Query Insights for pgvector instance"
  type        = bool
}

variable "pgvector_maintenance_window_day" {
  description = "Maintenance window day"
  type        = number
}

variable "pgvector_maintenance_window_hour" {
  description = "Maintenance window hour"
  type        = number
}

variable "pgvector_enable_read_replica" {
  description = "Enable read replica for pgvector instance"
  type        = bool
}

variable "pgvector_replica_region" {
  description = "Region for read replica"
  type        = string
}

variable "pgvector_replica_tier" {
  description = "Machine type for read replica"
  type        = string
}
