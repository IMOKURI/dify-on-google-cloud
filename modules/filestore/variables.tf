# =============================================================================
# Filestore Module Variables
# =============================================================================

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "location" {
  description = "Zone or Region for the Filestore instance (BASIC_HDD/BASIC_SSD: zone only, HIGH_SCALE_SSD/ENTERPRISE: zone or region)"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "filestore_tier" {
  description = "Filestore service tier (BASIC_HDD, BASIC_SSD, HIGH_SCALE_SSD, or ENTERPRISE)"
  type        = string
  default     = "BASIC_HDD"
}

variable "filestore_capacity_gb" {
  description = "Filestore capacity in GB"
  type        = number
  default     = 1024
}

variable "filestore_share_name" {
  description = "Name of the Filestore share"
  type        = string
  default     = "dify_volumes"
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_backup" {
  description = "Enable automatic backup for Filestore instance"
  type        = bool
  default     = false
}

variable "backup_location" {
  description = "Location for the Filestore backup (region)"
  type        = string
  default     = ""
}

variable "backup_labels" {
  description = "Labels to apply to backup"
  type        = map(string)
  default     = {}
}
