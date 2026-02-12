output "redis_instance_id" {
  description = "ID of the Redis instance"
  value       = google_redis_instance.dify_redis.id
}

output "redis_instance_name" {
  description = "Name of the Redis instance"
  value       = google_redis_instance.dify_redis.name
}

output "redis_host" {
  description = "Redis host IP address"
  value       = google_redis_instance.dify_redis.host
}

output "redis_port" {
  description = "Redis port"
  value       = google_redis_instance.dify_redis.port
}

output "redis_connection_string" {
  description = "Redis connection string (redis://<host>:<port> or redis://:<password>@<host>:<port>)"
  value       = var.auth_enabled ? "redis://:${google_redis_instance.dify_redis.auth_string}@${google_redis_instance.dify_redis.host}:${google_redis_instance.dify_redis.port}" : "redis://${google_redis_instance.dify_redis.host}:${google_redis_instance.dify_redis.port}"
  sensitive   = true
}

output "redis_current_location_id" {
  description = "Current location ID of the Redis instance"
  value       = google_redis_instance.dify_redis.current_location_id
}

output "redis_auth_string" {
  description = "Redis AUTH string (password, only available when auth_enabled is true)"
  value       = var.auth_enabled ? google_redis_instance.dify_redis.auth_string : null
  sensitive   = true
}
