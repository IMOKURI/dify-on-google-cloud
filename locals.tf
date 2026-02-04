locals {
  # ==========================================================================
  # SSH Key Management
  # ==========================================================================
  ssh_public_key_content  = fileexists("${path.module}/ssh/id_ed25519.pub") ? file("${path.module}/ssh/id_ed25519.pub") : var.ssh_public_key
  ssh_private_key_content = fileexists("${path.module}/ssh/id_ed25519") ? file("${path.module}/ssh/id_ed25519") : var.ssh_private_key

  # ==========================================================================
  # Common Labels/Tags
  # ==========================================================================
  common_labels = merge(
    {
      environment = "production"
      managed_by  = "terraform"
      project     = "dify-on-gcp"
      application = "dify"
    },
    var.gcs_labels
  )

  # ==========================================================================
  # Resource Naming
  # ==========================================================================
  resource_prefix = var.prefix

  # Database connection strings (for convenience)
  main_db_connection_string = "postgresql://${var.db_user}:${module.cloudsql.db_password}@${module.cloudsql.postgres_private_ip}:5432/${var.db_name}"

  pgvector_db_connection_string = format(
    "postgresql://%s:%s@%s/%s",
    var.pgvector_db_user,
    module.cloudsql.pgvector_db_password,
    module.cloudsql.pgvector_private_ip,
    var.pgvector_db_name
  )
}