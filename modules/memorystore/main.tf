# =============================================================================
# Memorystore for Redis Module
# =============================================================================

resource "google_redis_instance" "dify_redis" {
  name                    = "${var.prefix}-redis"
  tier                    = var.redis_tier
  memory_size_gb          = var.redis_memory_size_gb
  region                  = var.region
  location_id             = var.zone
  alternative_location_id = var.redis_tier == "STANDARD_HA" ? var.alternative_zone : null

  authorized_network = var.network_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version     = var.redis_version
  display_name      = "${var.prefix}-redis"
  reserved_ip_range = var.redis_reserved_ip_range
  auth_enabled      = var.auth_enabled

  labels = var.labels

  # Redis configurations
  redis_configs = var.redis_configs

  # Maintenance policy
  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy_enabled ? [1] : []
    content {
      weekly_maintenance_window {
        day = var.maintenance_day
        start_time {
          hours   = var.maintenance_start_hour
          minutes = 0
          seconds = 0
          nanos   = 0
        }
      }
    }
  }

  depends_on = [var.private_vpc_connection_id]
}
