# =============================================================================
# Load Balancer Module - Health Check, Backend Service, URL Map, SSL, and Forwarding Rule
# =============================================================================

# Health Check
resource "google_compute_health_check" "dify_health_check" {
  name                = "${var.prefix}-health-check"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 80
    request_path = "/"
  }
}

# Backend Service
resource "google_compute_backend_service" "dify_backend" {
  name                  = "${var.prefix}-backend"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  enable_cdn            = false
  health_checks         = [google_compute_health_check.dify_health_check.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = var.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    max_utilization = 0.8
  }
}

# URL Map
resource "google_compute_url_map" "dify_url_map" {
  name            = "${var.prefix}-url-map"
  default_service = google_compute_backend_service.dify_backend.id
}

# SSL Certificate (Google-managed)
resource "google_compute_managed_ssl_certificate" "dify_ssl_cert" {
  count = var.domain_name != "" ? 1 : 0
  name  = "${var.prefix}-ssl-cert"

  managed {
    domains = [var.domain_name]
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Self-signed SSL Certificate (for testing without domain)
resource "google_compute_ssl_certificate" "dify_self_signed" {
  count       = var.domain_name == "" ? 1 : 0
  name        = "${var.prefix}-self-signed-cert"
  private_key = var.ssl_private_key
  certificate = var.ssl_certificate

  lifecycle {
    create_before_destroy = true
  }
}

# HTTPS Proxy
resource "google_compute_target_https_proxy" "dify_https_proxy" {
  name    = "${var.prefix}-https-proxy"
  url_map = google_compute_url_map.dify_url_map.id
  ssl_certificates = var.domain_name != "" ? [
    google_compute_managed_ssl_certificate.dify_ssl_cert[0].id
    ] : [
    google_compute_ssl_certificate.dify_self_signed[0].id
  ]
}

# Global Forwarding Rule (HTTPS)
resource "google_compute_global_forwarding_rule" "dify_https_forwarding_rule" {
  name                  = "${var.prefix}-https-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.dify_https_proxy.id
  ip_address            = var.lb_ip_address
}
