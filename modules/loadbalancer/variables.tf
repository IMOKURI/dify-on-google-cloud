variable "prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "instance_group" {
  description = "Managed instance group URL"
  type        = string
}

variable "lb_ip_address" {
  description = "Load balancer IP address"
  type        = string
}

variable "domain_name" {
  description = "Domain name for SSL certificate"
  type        = string
}

variable "ssl_certificate" {
  description = "Self-signed SSL certificate (PEM format)"
  type        = string
  sensitive   = true
}

variable "ssl_private_key" {
  description = "Self-signed SSL private key (PEM format)"
  type        = string
  sensitive   = true
}
