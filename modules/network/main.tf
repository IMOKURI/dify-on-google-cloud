# =============================================================================
# Network Module - VPC, Subnet, Firewall Rules, and Private Service Connection
# =============================================================================

# VPC Network
resource "google_compute_network" "network" {
  name                    = "${var.prefix}-network"
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.network.id
}

# Firewall Rules - Allow HTTP/HTTPS from Load Balancer
resource "google_compute_firewall" "allow_lb" {
  name    = "${var.prefix}-allow-lb"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["1080", "443"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"] # Google Cloud Load Balancer IP ranges
  target_tags   = ["dify-instance"]
}

# Firewall Rules - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.prefix}-allow-ssh"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.ssh_source_ranges
  target_tags   = ["dify-instance"]
}

# Firewall Rules - Allow Health Check
resource "google_compute_firewall" "allow_health_check" {
  name    = "${var.prefix}-allow-health-check"
  network = google_compute_network.network.name

  allow {
    protocol = "tcp"
    ports    = ["1080"]
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
  target_tags   = ["dify-instance"]
}

# Static IP for Load Balancer
resource "google_compute_global_address" "lb_ip" {
  name = "${var.prefix}-lb-ip"
}

# =============================================================================
# Private Service Connection for Cloud SQL
# =============================================================================

# Private Service Connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.prefix}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
