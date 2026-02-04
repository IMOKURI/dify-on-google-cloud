# =============================================================================
# Cloud SQL - Main PostgreSQL Outputs
# =============================================================================

output "cloudsql_instance_name" {
  description = "Cloud SQL instance name"
  value       = module.cloudsql.postgres_instance_name
}

output "cloudsql_connection_name" {
  description = "Cloud SQL connection name"
  value       = module.cloudsql.postgres_connection_name
}

output "cloudsql_private_ip" {
  description = "Cloud SQL private IP address"
  value       = module.cloudsql.postgres_private_ip
}

output "cloudsql_public_ip" {
  description = "Cloud SQL public IP address"
  value       = null
}

output "database_name" {
  description = "Database name"
  value       = var.db_name
}

output "database_user" {
  description = "Database user"
  value       = var.db_user
  sensitive   = true
}

output "database_password" {
  description = "Database password"
  value       = module.cloudsql.db_password
  sensitive   = true
}

output "database_url" {
  description = "PostgreSQL connection URL (use private IP for VM)"
  value       = "postgresql://${var.db_user}:${module.cloudsql.db_password}@${module.cloudsql.postgres_private_ip}:5432/${var.db_name}"
  sensitive   = true
}

# =============================================================================
# Cloud SQL - pgvector Outputs
# =============================================================================

output "pgvector_instance_name" {
  description = "Name of the pgvector Cloud SQL instance"
  value       = module.cloudsql.pgvector_instance_name
}

output "pgvector_connection_name" {
  description = "Connection name for the pgvector Cloud SQL instance"
  value       = module.cloudsql.pgvector_connection_name
}

output "pgvector_private_ip" {
  description = "Private IP address of the pgvector Cloud SQL instance"
  value       = module.cloudsql.pgvector_private_ip
}

output "pgvector_public_ip" {
  description = "Public IP address of the pgvector Cloud SQL instance (if enabled)"
  value       = null
}

output "pgvector_database_name" {
  description = "Database name for pgvector"
  value       = var.pgvector_db_name
}

output "pgvector_database_user" {
  description = "Database user for pgvector"
  value       = var.pgvector_db_user
}

output "pgvector_database_password" {
  description = "Database password for pgvector"
  value       = module.cloudsql.pgvector_db_password
  sensitive   = true
}

output "pgvector_database_url" {
  description = "PostgreSQL connection URL for pgvector"
  value = format(
    "postgresql://%s:%s@%s/%s",
    var.pgvector_db_user,
    module.cloudsql.pgvector_db_password,
    module.cloudsql.pgvector_private_ip,
    var.pgvector_db_name
  )
  sensitive = true
}

output "pgvector_replica_instance_name" {
  description = "Name of the pgvector read replica instance"
  value       = null
}

output "pgvector_replica_private_ip" {
  description = "Private IP address of the pgvector read replica"
  value       = null
}
