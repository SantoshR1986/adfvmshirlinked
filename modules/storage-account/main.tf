# =============================================================================
# Azure Storage Account – AVM Module
# =============================================================================
module "storage_account" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.4"

  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
  location            = var.location

  account_tier             = var.account_tier
  account_replication_type = var.replication_type
  account_kind             = "StorageV2"
  access_tier              = var.access_tier

  # Lockdown public access
  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  network_rules = {
    default_action = "Deny"
    bypass         = ["AzureServices"]
  }

  # Blob service properties
  blob_properties = {
    versioning_enabled       = var.enable_versioning
    change_feed_enabled      = var.enable_change_feed
    last_access_time_enabled = true

    delete_retention_policy = {
      days = var.blob_soft_delete_days
    }

    container_delete_retention_policy = {
      days = var.container_soft_delete_days
    }
  }

  # Containers
  containers = {
    for name, cfg in var.containers : name => {
      name                  = name
      container_access_type = cfg.access_type
    }
  }

  tags = var.tags
}

# =============================================================================
# Role Assignment – ADF Managed Identity → Storage Blob Data Contributor
# =============================================================================
resource "azurerm_role_assignment" "adf_blob_contributor" {
  scope                = module.storage_account.resource_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.adf_identity_principal_id
}
