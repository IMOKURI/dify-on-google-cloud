output "load_balancer_ip" {
  description = "Load Balancer IP address"
  value       = module.network.lb_ip_address
}

output "instance_group_manager_name" {
  description = "Managed Instance Group name"
  value       = module.compute.instance_group_id
}

output "instance_group_manager_region" {
  description = "Managed Instance Group region"
  value       = var.region
}

output "autoscaling_enabled" {
  description = "Whether autoscaling is enabled"
  value       = var.autoscaling_enabled
}

output "autoscaling_min_replicas" {
  description = "Minimum number of instances"
  value       = var.autoscaling_min_replicas
}

output "autoscaling_max_replicas" {
  description = "Maximum number of instances (if autoscaling enabled)"
  value       = var.autoscaling_enabled ? var.autoscaling_max_replicas : null
}

output "https_url" {
  description = "HTTPS URL to access the application"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "https://${module.network.lb_ip_address}"
}

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
# pgvector Outputs
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

# =============================================================================
# Google Cloud Storage Outputs
# =============================================================================

output "gcs_bucket_name" {
  description = "Name of the GCS bucket"
  value       = module.storage.bucket_name
}

output "gcs_bucket_url" {
  description = "URL of the GCS bucket"
  value       = module.storage.bucket_url
}

output "gcs_bucket_self_link" {
  description = "Self link of the GCS bucket"
  value       = module.storage.bucket_self_link
}

output "service_account_email" {
  description = "Email of the Dify service account"
  value       = module.iam.service_account_email
}

output "google_storage_service_account_json_base64" {
  description = "Base64-encoded service account JSON key for Google Storage access (only if create_service_account_key is true)"
  value       = var.create_service_account_key ? module.iam.service_account_key : "Not created - VM uses default service account"
  sensitive   = true
}

# =============================================================================
# Redis Memorystore Outputs
# =============================================================================

output "redis_instance_name" {
  description = "Name of the Redis Memorystore instance"
  value       = "${var.prefix}-redis"
}

output "redis_host" {
  description = "Host (IP address) of the Redis instance"
  value       = module.redis.redis_host
}

output "redis_port" {
  description = "Port of the Redis instance"
  value       = module.redis.redis_port
}

output "redis_current_location_id" {
  description = "The current zone where the Redis instance is located"
  value       = null
}

output "redis_read_endpoint" {
  description = "Read endpoint for the Redis instance (for read replicas)"
  value       = null
}

output "redis_read_endpoint_port" {
  description = "Port for the read endpoint"
  value       = null
}

output "redis_auth_string" {
  description = "Redis AUTH string (password)"
  value       = module.redis.redis_auth_string
  sensitive   = true
}

output "redis_connection_string" {
  description = "Redis connection string (redis://host:port)"
  value = format(
    "redis://%s:%d",
    module.redis.redis_host,
    module.redis.redis_port
  )
}

output "redis_connection_url" {
  description = "Redis connection URL with authentication (if enabled)"
  value = var.redis_auth_enabled ? format(
    "redis://:%s@%s:%d",
    module.redis.redis_auth_string,
    module.redis.redis_host,
    module.redis.redis_port
    ) : format(
    "redis://%s:%d",
    module.redis.redis_host,
    module.redis.redis_port
  )
  sensitive = true
}

output "redis_persistence_iam_identity" {
  description = "Cloud IAM identity for RDB persistence"
  value       = null
}

output "redis_server_ca_certs" {
  description = "List of server CA certificates for the instance"
  value       = null
  sensitive   = true
}

