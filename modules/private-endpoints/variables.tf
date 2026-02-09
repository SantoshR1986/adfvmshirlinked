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

variable "subnet_id" {
  description = "Subnet resource ID for private endpoints."
  type        = string
}

variable "endpoints" {
  description = "Map of private endpoints to create."
  type = map(object({
    resource_id          = string
    subresource_names    = list(string)
    private_dns_zone_ids = list(string)
  }))
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
