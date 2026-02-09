locals {
  # Naming convention: {project}-{resource_type}-{environment}-{location_short}
  location_short = lookup({
    "eastus"         = "eus"
    "eastus2"        = "eus2"
    "westus"         = "wus"
    "westus2"        = "wus2"
    "centralus"      = "cus"
    "northeurope"    = "neu"
    "westeurope"     = "weu"
    "uksouth"        = "uks"
    "ukwest"         = "ukw"
    "southeastasia"  = "sea"
    "australiaeast"  = "aue"
  }, var.location, substr(var.location, 0, 4))

  name_prefix = "${var.project_name}-${var.environment}-${local.location_short}"

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "rg-${local.name_prefix}"

  common_tags = merge(var.tags, {
    environment = var.environment
    project     = var.project_name
    managed_by  = "terraform"
  })

  # Private DNS zone names per service
  dns_zone_names = {
    datafactory = "privatelink.datafactory.azure.net"
    vault       = "privatelink.vaultcore.azure.net"
    blob        = "privatelink.blob.core.windows.net"
    sqlServer   = "privatelink.database.windows.net"
  }

  # Subnet references
  pe_subnet_name   = "snet-private-endpoints"
  shir_subnet_name = "snet-shir"
}
