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

variable "cloudsql_availability_type" {
  description = "Availability type for Cloud SQL"
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

variable "pgvector_backup_enabled" {
  description = "Enable automated backups for pgvector instance"
  type        = bool
}

variable "pgvector_backup_start_time" {
  description = "Backup start time for pgvector instance"
  type        = string
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