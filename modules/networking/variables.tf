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

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "Map of subnet name to configuration."
  type = map(object({
    address_prefix                    = string
    private_endpoint_network_policies = optional(string, "Enabled")
  }))
}

variable "dns_zone_names" {
  description = "Map of logical key to private DNS zone name."
  type        = map(string)
}

variable "existing_dns_zones" {
  description = "Map of logical key to existing private DNS zone resource IDs."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
