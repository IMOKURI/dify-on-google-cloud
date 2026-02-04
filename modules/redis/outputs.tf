output "redis_host" {
  description = "Redis host address"
  value       = google_redis_instance.dify_redis.host
}

output "redis_port" {
  description = "Redis port"
  value       = google_redis_instance.dify_redis.port
}

output "redis_auth_string" {
  description = "Redis AUTH string (if AUTH is enabled)"
  value       = var.auth_enabled ? google_redis_instance.dify_redis.auth_string : ""
  sensitive   = true
}

output "redis_instance_id" {
  description = "Redis instance ID"
  value       = google_redis_instance.dify_redis.id
}
