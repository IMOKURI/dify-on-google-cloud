# =============================================================================
# Cloud SQL Module - PostgreSQL and pgvector instances
# =============================================================================

# Random password for Cloud SQL (if not provided)
resource "random_password" "db_password" {
  count   = var.db_password == "" ? 1 : 0
  length  = 32
  special = true
}

# Random password for pgvector Cloud SQL (if not provided)
resource "random_password" "pgvector_db_password" {
  count   = var.pgvector_db_password == "" ? 1 : 0
  length  = 32
  special = true
}

# =============================================================================
# Main Cloud SQL PostgreSQL Instance
# =============================================================================

# Cloud SQL PostgreSQL Instance
resource "google_sql_database_instance" "dify_postgres" {
  name             = "${var.prefix}-postgres"
  database_version = var.cloudsql_database_version
  region           = var.region

  deletion_protection = true

  settings {
    tier              = var.cloudsql_tier
    disk_size         = var.cloudsql_disk_size
    disk_type         = "PD_SSD"
    availability_type = "ZONAL" # Use REGIONAL for high availability

    backup_configuration {
      enabled                        = var.cloudsql_backup_enabled
      start_time                     = var.cloudsql_backup_start_time
      point_in_time_recovery_enabled = var.cloudsql_backup_enabled
      transaction_log_retention_days = var.cloudsql_backup_enabled ? 7 : null

      dynamic "backup_retention_settings" {
        for_each = var.cloudsql_backup_enabled ? [1] : []
        content {
          retained_backups = 7
          retention_unit   = "COUNT"
        }
      }
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
      ssl_mode        = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    database_flags {
      name  = "max_connections"
      value = "100"
    }

    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 3
      update_track = "stable"
    }
  }

  depends_on = [
    var.private_vpc_connection_id
  ]
}

# Database
resource "google_sql_database" "dify_db" {
  name     = var.db_name
  instance = google_sql_database_instance.dify_postgres.name
}

# Plugin Database
resource "google_sql_database" "dify_plugin_db" {
  name     = "${var.db_name}_plugin"
  instance = google_sql_database_instance.dify_postgres.name
}

# Database User
resource "google_sql_user" "dify_user" {
  name     = var.db_user
  instance = google_sql_database_instance.dify_postgres.name
  password = var.db_password != "" ? var.db_password : random_password.db_password[0].result
}

# =============================================================================
# pgvector Cloud SQL Instance
# =============================================================================

# Cloud SQL PostgreSQL Instance with pgvector extension
resource "google_sql_database_instance" "dify_pgvector" {
  name             = "${var.prefix}-pgvector"
  database_version = var.pgvector_database_version
  region           = var.region

  deletion_protection = var.pgvector_deletion_protection

  settings {
    tier              = var.pgvector_tier
    disk_size         = var.pgvector_disk_size
    disk_type         = "PD_SSD"
    availability_type = var.pgvector_availability_type

    backup_configuration {
      enabled                        = var.pgvector_backup_enabled
      start_time                     = var.pgvector_backup_start_time
      point_in_time_recovery_enabled = var.pgvector_backup_enabled
      transaction_log_retention_days = var.pgvector_backup_enabled ? 7 : null

      dynamic "backup_retention_settings" {
        for_each = var.pgvector_backup_enabled ? [1] : []
        content {
          retained_backups = var.pgvector_backup_retention_count
          retention_unit   = "COUNT"
        }
      }
    }

    ip_configuration {
      ipv4_enabled    = var.pgvector_enable_public_ip
      private_network = var.network_id
      ssl_mode        = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"

      dynamic "authorized_networks" {
        for_each = var.pgvector_authorized_networks
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.cidr
        }
      }
    }

    # Database flags for pgvector optimization
    database_flags {
      name  = "max_connections"
      value = var.pgvector_max_connections
    }

    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }

    insights_config {
      query_insights_enabled  = var.pgvector_query_insights_enabled
      query_plans_per_minute  = var.pgvector_query_insights_enabled ? 5 : null
      query_string_length     = var.pgvector_query_insights_enabled ? 1024 : null
      record_application_tags = var.pgvector_query_insights_enabled ? true : null
    }

    maintenance_window {
      day          = var.pgvector_maintenance_window_day
      hour         = var.pgvector_maintenance_window_hour
      update_track = "stable"
    }
  }

  depends_on = [
    var.private_vpc_connection_id
  ]
}

# Database for vector storage
resource "google_sql_database" "pgvector_db" {
  name     = var.pgvector_db_name
  instance = google_sql_database_instance.dify_pgvector.name
}

# Database User for pgvector
resource "google_sql_user" "pgvector_user" {
  name     = var.pgvector_db_user
  instance = google_sql_database_instance.dify_pgvector.name
  password = var.pgvector_db_password != "" ? var.pgvector_db_password : random_password.pgvector_db_password[0].result
}

# Optional: Create a read replica for high availability and read scaling
resource "google_sql_database_instance" "dify_pgvector_replica" {
  count                = var.pgvector_enable_read_replica ? 1 : 0
  name                 = "${var.prefix}-pgvector-replica"
  master_instance_name = google_sql_database_instance.dify_pgvector.name
  region               = var.pgvector_replica_region != "" ? var.pgvector_replica_region : var.region
  database_version     = var.pgvector_database_version

  deletion_protection = var.pgvector_deletion_protection

  replica_configuration {
    failover_target = false
  }

  settings {
    tier              = var.pgvector_replica_tier != "" ? var.pgvector_replica_tier : var.pgvector_tier
    disk_size         = var.pgvector_disk_size
    disk_type         = "PD_SSD"
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled    = var.pgvector_enable_public_ip
      private_network = var.network_id
      ssl_mode        = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    # Inherit database flags from master
    database_flags {
      name  = "max_connections"
      value = var.pgvector_max_connections
    }

    insights_config {
      query_insights_enabled = var.pgvector_query_insights_enabled
    }
  }
}
