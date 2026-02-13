# =============================================================================
# Backup Scheduler Module Variables
# =============================================================================

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for Cloud Functions and Cloud Scheduler"
  type        = string
}

variable "enable_backup_scheduler" {
  description = "Enable automated backup scheduler"
  type        = bool
  default     = false
}

variable "backup_schedule" {
  description = "Cron schedule for backups (default: daily at 2:00 AM)"
  type        = string
  default     = "0 2 * * *"
}

variable "backup_timezone" {
  description = "Timezone for backup schedule"
  type        = string
  default     = "Asia/Tokyo"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups (0 = keep all)"
  type        = number
  default     = 7
}

variable "filestore_instance_id" {
  description = "Full resource ID of the Filestore instance"
  type        = string
}

variable "filestore_location" {
  description = "Location of the Filestore instance"
  type        = string
}

variable "filestore_share_name" {
  description = "Name of the Filestore share to backup"
  type        = string
}

variable "backup_location" {
  description = "Location for backups (defaults to filestore_location if empty)"
  type        = string
  default     = ""
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
