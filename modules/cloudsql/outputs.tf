output "postgres_instance_name" {
  description = "Name of the PostgreSQL instance"
  value       = google_sql_database_instance.dify_postgres.name
}

output "postgres_private_ip" {
  description = "Private IP address of the PostgreSQL instance"
  value       = google_sql_database_instance.dify_postgres.private_ip_address
}

output "postgres_connection_name" {
  description = "Connection name of the PostgreSQL instance"
  value       = google_sql_database_instance.dify_postgres.connection_name
}

output "db_password" {
  description = "Database password for main instance"
  value       = var.db_password != "" ? var.db_password : random_password.db_password[0].result
  sensitive   = true
}

output "pgvector_instance_name" {
  description = "Name of the pgvector instance"
  value       = google_sql_database_instance.dify_pgvector.name
}

output "pgvector_private_ip" {
  description = "Private IP address of the pgvector instance"
  value       = google_sql_database_instance.dify_pgvector.private_ip_address
}

output "pgvector_connection_name" {
  description = "Connection name of the pgvector instance"
  value       = google_sql_database_instance.dify_pgvector.connection_name
}

output "pgvector_db_password" {
  description = "Database password for pgvector instance"
  value       = var.pgvector_db_password != "" ? var.pgvector_db_password : random_password.pgvector_db_password[0].result
  sensitive   = true
}
