# =============================================================================
# Virtual Network – AVM Module
# =============================================================================
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.7"

  name                = "vnet-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.vnet_address_space

  subnets = {
    for name, cfg in var.subnet_prefixes : name => {
      name                                      = name
      address_prefix                            = cfg.address_prefix
      private_endpoint_network_policies = cfg.private_endpoint_network_policies
    }
  }

  tags = var.tags
}

# =============================================================================
# Private DNS Zones – create only where an existing zone ID was NOT provided
# =============================================================================
module "private_dns_zone" {
  source   = "Azure/avm-res-network-privatednszone/azurerm"
  version  = "~> 0.2"
  for_each = { for k, v in var.dns_zone_names : k => v if !contains(keys(var.existing_dns_zones), k) }

  domain_name         = each.value
  resource_group_name = var.resource_group_name

  virtual_network_links = {
    vnet_link = {
      vnetlinkname = "vlink-${each.key}-${var.name_prefix}"
      vnetid       = module.vnet.resource_id
    }
  }

  tags = var.tags
}
