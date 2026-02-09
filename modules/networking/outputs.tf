output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = module.vnet.resource_id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = module.vnet.name
}

output "subnet_ids" {
  description = "Map of subnet name to resource ID."
  value       = { for k, v in module.vnet.subnets : k => v.resource_id }
}

output "private_dns_zone_ids" {
  description = "Merged map of private DNS zone logical key to resource ID (existing + newly created)."
  value = merge(
    var.existing_dns_zones,
    { for k, v in module.private_dns_zone : k => v.resource_id }
  )
}
