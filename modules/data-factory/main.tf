# =============================================================================
# Azure Data Factory – AVM Module
# =============================================================================
module "adf" {
  source  = "Azure/avm-res-datafactory-factory/azurerm"
  version = "~> 0.5"

  name                = "adf-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location

  public_network_enabled = var.public_network_enabled

  managed_identities = {
    system_assigned = true
  }

  tags = var.tags
}

# =============================================================================
# Self-Hosted Integration Runtime (resource inside ADF)
# =============================================================================
resource "azurerm_data_factory_integration_runtime_self_hosted" "shir" {
  name            = "shir-${var.name_prefix}"
  data_factory_id = module.adf.resource_id
}
