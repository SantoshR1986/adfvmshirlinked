variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "name_prefix" {
  description = "Naming prefix."
  type        = string
}

variable "node_count" {
  description = "Number of SHIR VM nodes. All register with the same auth key. Use 2+ for HA."
  type        = number
  default     = 1
  validation {
    condition     = var.node_count >= 1 && var.node_count <= 4
    error_message = "Azure supports 1 to 4 nodes per self-hosted integration runtime."
  }
}

variable "vm_size" {
  description = "VM SKU size."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "admin_username" {
  description = "Local administrator username."
  type        = string
}

variable "admin_password" {
  description = "Local administrator password."
  type        = string
  sensitive   = true
}

variable "vm_image" {
  description = "Windows image reference."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "subnet_id" {
  description = "Subnet resource ID where the SHIR VM NIC is placed."
  type        = string
}

variable "shir_auth_key" {
  description = "Primary authorization key from the ADF SHIR integration runtime."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
