# =============================================================================
# Private Endpoints – generic module using AVM
# Creates one private endpoint per entry in var.endpoints.
# =============================================================================
module "private_endpoint" {
  source   = "Azure/avm-res-network-privateendpoint/azurerm"
  version  = "~> 0.2"
  for_each = var.endpoints

  name                = "pe-${each.key}-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_resource_id  = var.subnet_id

  private_connection_resource_id = each.value.resource_id
  subresource_names              = each.value.subresource_names

  private_dns_zone_group = {
    zone_group = {
      name                 = "default"
      private_dns_zone_ids = each.value.private_dns_zone_ids
    }
  }

  tags = var.tags
}
