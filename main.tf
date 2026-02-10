terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# =============================================================================
# IAM Module - Service Account for Dify application
# =============================================================================

module "iam" {
  source = "./modules/iam"

  prefix     = var.prefix
  project_id = var.project_id
  labels     = var.labels
}

# =============================================================================
# Network Module - VPC, Subnet, and Private Service Access
# =============================================================================

module "network" {
  source = "./modules/network"

  prefix            = var.prefix
  region            = var.region
  subnet_cidr       = var.subnet_cidr
  ssh_source_ranges = var.ssh_source_ranges
  labels            = var.labels
}

# =============================================================================
# Filestore Module - Managed NFS for Dify volumes
# =============================================================================

module "filestore" {
  source = "./modules/filestore"

  prefix                = var.prefix
  location              = var.availability_type == "REGIONAL" ? var.region : var.zone
  network_name          = module.network.network_name
  filestore_tier        = var.filestore_tier
  filestore_capacity_gb = var.filestore_capacity_gb
  filestore_share_name  = var.filestore_share_name

  labels = var.labels

  depends_on = [
    module.network
  ]
}

# =============================================================================
# Cloud SQL Module - PostgreSQL databases for Dify
# =============================================================================
# Creates two PostgreSQL instances:
# 1. Main database - for application data
# 2. pgvector database - for vector embeddings and similarity search
# =============================================================================

module "cloudsql" {
  source = "./modules/cloudsql"

  prefix                    = var.prefix
  region                    = var.region
  zone                      = var.zone
  availability_type         = var.availability_type
  network_id                = module.network.network_id
  private_vpc_connection_id = module.network.private_vpc_connection_id

  # Main PostgreSQL instance configuration
  cloudsql_tier              = var.cloudsql_tier
  cloudsql_disk_size         = var.cloudsql_disk_size
  cloudsql_database_version  = var.cloudsql_database_version
  cloudsql_backup_enabled    = var.cloudsql_backup_enabled
  cloudsql_backup_start_time = var.cloudsql_backup_start_time
  db_name                    = var.db_name
  db_user                    = var.db_user
  db_password                = var.db_password

  # pgvector instance configuration
  pgvector_database_version  = var.pgvector_database_version
  pgvector_tier              = var.pgvector_tier
  pgvector_disk_size         = var.pgvector_disk_size
  pgvector_backup_enabled    = var.pgvector_backup_enabled
  pgvector_backup_start_time = var.pgvector_backup_start_time
  pgvector_db_name           = var.pgvector_db_name
  pgvector_db_user           = var.pgvector_db_user
  pgvector_db_password       = var.pgvector_db_password

  labels = var.labels

  depends_on = [
    module.network
  ]
}

# =============================================================================
# Compute Module - Managed Instance Group
# =============================================================================

module "compute" {
  source = "./modules/compute"

  prefix       = var.prefix
  region       = var.region
  network_name = module.network.network_name
  subnet_name  = module.network.subnet_name

  # Instance configuration
  machine_type          = var.machine_type
  disk_size_gb          = var.disk_size_gb
  service_account_email = module.iam.service_account_email

  # Startup script with all service configurations
  startup_script = templatefile("${path.module}/assets/startup-script.sh", {
    db_host                    = module.cloudsql.postgres_private_ip
    database_user              = var.db_user
    database_password          = module.cloudsql.db_password
    database_name              = var.db_name
    pgvector_private_ip        = module.cloudsql.pgvector_private_ip
    pgvector_database_user     = var.pgvector_db_user
    pgvector_database_password = module.cloudsql.pgvector_db_password
    pgvector_database_name     = var.pgvector_db_name
    filestore_ip               = module.filestore.filestore_ip
    filestore_share_name       = module.filestore.filestore_share_name
    dify_version               = var.dify_version
  })

  # Sandbox python requirements file content
  python_requirements = file("${path.module}/assets/sandbox/python-requirements.txt")

  # Sandbox configuration file content
  sandbox_config = file("${path.module}/assets/sandbox/config.yaml")

  labels = var.labels

  depends_on = [
    module.iam,
    module.network,
    module.filestore,
    module.cloudsql
  ]
}

# =============================================================================
# Load Balancer Module - HTTPS Load Balancer with SSL termination
# =============================================================================
# Note: Health check is created in compute module and shared with load balancer.
# Backend service is created after compute module creates the instance group.
# =============================================================================

module "loadbalancer" {
  source = "./modules/loadbalancer"

  prefix          = var.prefix
  health_check_id = module.compute.health_check_id
  instance_group  = module.compute.instance_group
  lb_ip_address   = module.network.lb_ip_address
  domain_name     = var.domain_name
  ssl_certificate = var.ssl_certificate
  ssl_private_key = var.ssl_private_key

  labels = var.labels

  depends_on = [
    module.network,
    module.compute
  ]
}
