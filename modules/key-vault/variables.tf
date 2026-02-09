variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix for resources."
  type        = string
}

variable "sku" {
  description = "Key Vault SKU."
  type        = string
  default     = "standard"
}

variable "admin_object_ids" {
  description = "Object IDs to grant Key Vault Administrator."
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secret name to value. Empty values are skipped."
  type        = map(string)
  sensitive   = true
  default     = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
