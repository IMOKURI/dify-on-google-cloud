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
    availability_type = var.cloudsql_availability_type

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
      day          = 6 # Saturday
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

  deletion_protection = true

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
      day          = 6 # Saturday
      hour         = 4
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
