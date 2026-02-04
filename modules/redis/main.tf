# =============================================================================
# Redis Module - Google Cloud Memorystore for Redis
# =============================================================================

# Random password for Redis AUTH (if enabled and not provided)
resource "random_password" "redis_auth_string" {
  count   = var.auth_enabled ? 1 : 0
  length  = 32
  special = false # Redis AUTH string should not contain special characters
}

# Redis Memorystore Instance
resource "google_redis_instance" "dify_redis" {
  name                    = "${var.prefix}-redis"
  tier                    = var.tier
  memory_size_gb          = var.memory_size_gb
  region                  = var.region
  redis_version           = var.redis_version
  replica_count           = var.tier == "STANDARD_HA" ? var.replica_count : null
  auth_enabled            = var.auth_enabled
  transit_encryption_mode = var.transit_encryption_mode
  connect_mode            = var.connect_mode
  authorized_network      = var.network_id
  reserved_ip_range       = var.reserved_ip_range != "" ? var.reserved_ip_range : null

  # Persistence configuration (only for STANDARD_HA tier)
  dynamic "persistence_config" {
    for_each = var.tier == "STANDARD_HA" && var.persistence_mode == "RDB" ? [1] : []
    content {
      persistence_mode        = "RDB"
      rdb_snapshot_period     = var.rdb_snapshot_period
      rdb_snapshot_start_time = var.rdb_snapshot_start_time != "" ? var.rdb_snapshot_start_time : null
    }
  }

  # Maintenance policy
  maintenance_policy {
    weekly_maintenance_window {
      day = var.maintenance_window_day
      start_time {
        hours   = var.maintenance_window_hour
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }

  # Redis configuration parameters
  redis_configs = {
    # Timeout for idle connections (in seconds)
    "timeout" = "300"

    # Maximum number of connected clients
    "maxmemory-policy" = "allkeys-lru"

    # Notify keyspace events
    "notify-keyspace-events" = ""
  }

  labels = merge(
    {
      environment = var.prefix
      managed_by  = "terraform"
    },
    var.labels
  )

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [
    var.private_vpc_connection_id
  ]
}
