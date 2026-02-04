# =============================================================================
# Application Configuration
# =============================================================================

variable "docker_compose_version" {
  description = "Docker Compose version to install"
  type        = string
  default     = "v2.24.5"
}

variable "dify_version" {
  description = "Dify version to download and deploy"
  type        = string
  default     = "1.12.0"
}
