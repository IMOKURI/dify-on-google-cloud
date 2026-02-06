# =============================================================================
# Filestore Module Variables
# =============================================================================

variable "prefix" {
  description = "Prefix for all resources"
  type        = string
}

variable "zone" {
  description = "Zone for the Filestore instance"
  type        = string
}

variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "filestore_tier" {
  description = "Filestore service tier (BASIC_HDD, BASIC_SSD, HIGH_SCALE_SSD, or ENTERPRISE)"
  type        = string
  default     = "BASIC_SSD"
}

variable "filestore_capacity_gb" {
  description = "Filestore capacity in GB"
  type        = number
  default     = 2560
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
