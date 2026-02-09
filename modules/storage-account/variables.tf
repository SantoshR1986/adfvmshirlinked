variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 chars, lowercase alphanumeric)."
  type        = string
}

variable "account_tier" {
  description = "Storage account tier."
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "Replication type (LRS, GRS, ZRS, GZRS, RA-GRS, RA-GZRS)."
  type        = string
  default     = "GRS"
}

variable "access_tier" {
  description = "Default access tier (Hot or Cool)."
  type        = string
  default     = "Hot"
}

variable "enable_versioning" {
  description = "Enable blob versioning."
  type        = bool
  default     = true
}

variable "enable_change_feed" {
  description = "Enable blob change feed."
  type        = bool
  default     = true
}

variable "blob_soft_delete_days" {
  description = "Blob soft delete retention in days."
  type        = number
  default     = 30
}

variable "container_soft_delete_days" {
  description = "Container soft delete retention in days."
  type        = number
  default     = 30
}

variable "containers" {
  description = "Map of blob containers to create."
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

variable "adf_identity_principal_id" {
  description = "Principal ID of the ADF system-assigned managed identity for RBAC."
  type        = string
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
