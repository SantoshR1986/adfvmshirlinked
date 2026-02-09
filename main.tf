# =============================================================================
# Resource Group
# =============================================================================
resource "azurerm_resource_group" "this" {
  name     = local.resource_group_name
  location = var.location
  tags     = local.common_tags
}

# =============================================================================
# Networking – VNet, Subnets, Private DNS Zones
# =============================================================================
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name_prefix         = local.name_prefix
  vnet_address_space  = var.vnet_address_space
  subnet_prefixes     = var.subnet_prefixes
  dns_zone_names      = local.dns_zone_names
  existing_dns_zones  = var.private_dns_zone_ids
  tags                = local.common_tags
}

# =============================================================================
# Data Factory (AVM) with Managed Identity & SHIR
# =============================================================================
module "data_factory" {
  source = "./modules/data-factory"

  resource_group_name    = azurerm_resource_group.this.name
  location               = var.location
  name_prefix            = local.name_prefix
  public_network_enabled = var.data_factory_public_network_enabled
  tags                   = local.common_tags

  depends_on = [module.networking]
}

# =============================================================================
# Key Vault – stores SHIR auth key, VM password, Oracle connection string
# =============================================================================
module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name_prefix         = local.name_prefix
  sku                 = var.key_vault_sku
  admin_object_ids    = var.key_vault_admin_object_ids
  tags                = local.common_tags

  secrets = {
    "shir-auth-key"                            = module.data_factory.shir_primary_auth_key
    "shir-vm-admin-password"                   = var.shir_vm_admin_password
    (var.oracle_connection_string_secret_name)  = var.oracle_connection_string
  }

  depends_on = [module.networking]
}

# =============================================================================
# Storage Account (AVM) – Blob storage for ADF pipelines
# =============================================================================
module "storage_account" {
  source = "./modules/storage-account"

  resource_group_name   = azurerm_resource_group.this.name
  location              = var.location
  storage_account_name  = var.storage_account_name
  account_tier          = var.storage_account_tier
  replication_type      = var.storage_replication_type
  containers            = var.storage_containers
  adf_identity_principal_id = module.data_factory.identity_principal_id
  tags                  = local.common_tags

  depends_on = [module.data_factory, module.networking]
}

# =============================================================================
# Azure SQL Server & Database (AVM) – target for ADF pipelines
# =============================================================================
module "azure_sql" {
  source = "./modules/azure-sql"

  resource_group_name    = azurerm_resource_group.this.name
  location               = var.location
  sql_server_name        = var.sql_server_name
  sql_ad_admin_login     = var.sql_ad_admin_login
  sql_ad_admin_object_id = var.sql_ad_admin_object_id
  sql_ad_auth_only       = var.sql_ad_auth_only
  database_name          = var.sql_database_name
  database_sku           = var.sql_database_sku
  database_max_size_gb   = var.sql_database_max_size_gb
  database_zone_redundant = var.sql_database_zone_redundant
  tags                   = local.common_tags

  depends_on = [module.data_factory, module.networking]
}

# =============================================================================
# Self-Hosted Integration Runtime VM (Company Module)
# =============================================================================
module "shir_vm" {
  source = "./modules/shir-vm"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name_prefix         = local.name_prefix
  node_count          = var.shir_vm_node_count
  vm_size             = var.shir_vm_size
  admin_username      = var.shir_vm_admin_username
  admin_password      = var.shir_vm_admin_password
  vm_image            = var.shir_vm_image
  subnet_id           = module.networking.subnet_ids[local.shir_subnet_name]
  shir_auth_key       = module.data_factory.shir_primary_auth_key
  tags                = local.common_tags

  depends_on = [module.data_factory]
}

# =============================================================================
# Private Endpoints – ADF, Key Vault, Storage Account, SQL Server
# =============================================================================
module "private_endpoints" {
  source = "./modules/private-endpoints"

  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name_prefix         = local.name_prefix
  subnet_id           = module.networking.subnet_ids[local.pe_subnet_name]
  tags                = local.common_tags

  endpoints = {
    adf = {
      resource_id          = module.data_factory.data_factory_id
      subresource_names    = ["dataFactory"]
      private_dns_zone_ids = [module.networking.private_dns_zone_ids["datafactory"]]
    }
    kv = {
      resource_id          = module.key_vault.key_vault_id
      subresource_names    = ["vault"]
      private_dns_zone_ids = [module.networking.private_dns_zone_ids["vault"]]
    }
    blob = {
      resource_id          = module.storage_account.storage_account_id
      subresource_names    = ["blob"]
      private_dns_zone_ids = [module.networking.private_dns_zone_ids["blob"]]
    }
    sql = {
      resource_id          = module.azure_sql.sql_server_id
      subresource_names    = ["sqlServer"]
      private_dns_zone_ids = [module.networking.private_dns_zone_ids["sqlServer"]]
    }
  }

  depends_on = [module.networking]
}

# =============================================================================
# Linked Services (Blob, Azure SQL, On-prem Oracle)
# =============================================================================
module "linked_services" {
  source = "./modules/linked-services"

  data_factory_id   = module.data_factory.data_factory_id
  data_factory_name = module.data_factory.data_factory_name
  key_vault_id      = module.key_vault.key_vault_id
  key_vault_name    = module.key_vault.key_vault_name

  # SHIR reference for on-prem Oracle
  self_hosted_ir_name = module.data_factory.shir_integration_runtime_name

  # Blob Storage – references newly created storage account
  blob_storage_endpoint = module.storage_account.primary_blob_endpoint

  # Azure SQL – references newly created server & database
  azure_sql_server_fqdn   = module.azure_sql.sql_server_fqdn
  azure_sql_database_name = module.azure_sql.database_name

  # Oracle
  oracle_connection_string_secret_name = var.oracle_connection_string_secret_name

  depends_on = [
    module.data_factory,
    module.key_vault,
    module.storage_account,
    module.azure_sql,
  ]
}
