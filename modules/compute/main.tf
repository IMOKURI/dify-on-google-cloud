# =============================================================================
# Compute Module - Instance Template, MIG, and Autoscaler
# =============================================================================

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
    ssh-keys       = var.ssh_public_key_content != "" ? "${var.ssh_user}:${var.ssh_public_key_content}" : ""
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

# Managed Instance Group for Auto Scaling
resource "google_compute_region_instance_group_manager" "dify_mig" {
  name               = "${var.prefix}-mig"
  base_instance_name = "${var.prefix}-instance"
  region             = var.region

  version {
    instance_template = google_compute_instance_template.dify_template.id
  }

  target_size = var.autoscaling_enabled ? null : var.autoscaling_min_replicas

  named_port {
    name = "http"
    port = 1080
  }

  auto_healing_policies {
    health_check      = var.health_check_id
    initial_delay_sec = 300
  }

  update_policy {
    type                           = "PROACTIVE"
    instance_redistribution_type   = "PROACTIVE"
    minimal_action                 = "REPLACE"
    most_disruptive_allowed_action = "REPLACE"
    max_surge_fixed                = 3
    max_unavailable_fixed          = 0
    replacement_method             = "SUBSTITUTE"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Autoscaler for Managed Instance Group
resource "google_compute_region_autoscaler" "dify_autoscaler" {
  count  = var.autoscaling_enabled ? 1 : 0
  name   = "${var.prefix}-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.dify_mig.id

  autoscaling_policy {
    max_replicas    = var.autoscaling_max_replicas
    min_replicas    = var.autoscaling_min_replicas
    cooldown_period = var.autoscaling_cooldown_period

    cpu_utilization {
      target = var.autoscaling_cpu_target
    }

    dynamic "metric" {
      for_each = var.autoscaling_custom_metrics
      content {
        name   = metric.value.name
        target = metric.value.target
        type   = metric.value.type
      }
    }

    scale_in_control {
      max_scaled_in_replicas {
        fixed = var.autoscaling_scale_in_max_replicas
      }
      time_window_sec = var.autoscaling_scale_in_time_window
    }
  }
}
