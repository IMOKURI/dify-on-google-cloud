# =============================================================================
# Compute Module - Instance Template and MIG
# =============================================================================

# Health Check for MIG auto-healing and Load Balancer
resource "google_compute_health_check" "dify_health_check" {
  name                = "${var.prefix}-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/console/api/ping"
  }
}

# Instance Template with Docker
resource "google_compute_instance_template" "dify_template" {
  name_prefix  = "${var.prefix}-template-"
  machine_type = var.machine_type
  tags         = ["dify-instance"]

  disk {
    source_image = "ubuntu-os-cloud/ubuntu-2204-lts"
    auto_delete  = true
    boot         = true
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"
  }

  network_interface {
    network    = var.network_name
    subnetwork = var.subnet_name

    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    startup-script = var.startup_script
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Managed Instance Group
resource "google_compute_region_instance_group_manager" "dify_mig" {
  name               = "${var.prefix}-mig"
  base_instance_name = "${var.prefix}-instance"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.dify_template.id
  }

  target_size = 1

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.dify_health_check.id
    initial_delay_sec = 900
  }

  update_policy {
    type                           = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 0
    max_unavailable_fixed          = 3
    replacement_method             = "SUBSTITUTE"
  }

  depends_on = [
    google_compute_instance_template.dify_template
  ]

  lifecycle {
    create_before_destroy = false
  }
}
