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
