# =============================================================================
# Filestore Configuration Variables
# =============================================================================

variable "filestore_tier" {
  description = "Filestore service tier (BASIC_HDD, BASIC_SSD, HIGH_SCALE_SSD, or ENTERPRISE)"
  type        = string
  default     = "BASIC_SSD"
}

variable "filestore_capacity_gb" {
  description = "Filestore capacity in GB (minimum 1024 GB for BASIC_HDD, 2560 GB for BASIC_SSD)"
  type        = number
  default     = 2560
}

variable "filestore_share_name" {
  description = "Name of the Filestore share"
  type        = string
  default     = "dify_volumes"
}
