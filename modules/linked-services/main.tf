# =============================================================================
# ADF Linked Service – Key Vault (base reference for secret lookups)
# =============================================================================
resource "azurerm_data_factory_linked_service_key_vault" "this" {
  name            = "ls-keyvault"
  data_factory_id = var.data_factory_id
  key_vault_id    = var.key_vault_id
}

# =============================================================================
# ADF Linked Service – Azure Blob Storage (managed identity auth)
# =============================================================================
resource "azurerm_data_factory_linked_service_azure_blob_storage" "this" {
  name                 = "ls-blob-storage"
  data_factory_id      = var.data_factory_id
  use_managed_identity = true
  service_endpoint     = var.blob_storage_endpoint
}

# =============================================================================
# ADF Linked Service – Azure SQL Database (managed identity auth)
# =============================================================================
resource "azurerm_data_factory_linked_service_azure_sql_database" "this" {
  name                 = "ls-azure-sql"
  data_factory_id      = var.data_factory_id
  use_managed_identity = true
  connection_string = join(";", [
    "Server=tcp:${var.azure_sql_server_fqdn},1433",
    "Database=${var.azure_sql_database_name}",
    "Encrypt=True",
    "TrustServerCertificate=False",
    "Connection Timeout=30",
  ])
}

# =============================================================================
# ADF Linked Service – On-prem Oracle (via SHIR + Key Vault secret)
#
# The Oracle connection string is stored in Key Vault; ADF resolves it at
# runtime through the Key Vault linked service reference.
# =============================================================================
resource "azurerm_data_factory_linked_custom_service" "oracle" {
  name            = "ls-oracle-onprem"
  data_factory_id = var.data_factory_id
  type            = "Oracle"

  type_properties_json = jsonencode({
    connectionString = {
      type = "AzureKeyVaultSecret"
      store = {
        referenceName = azurerm_data_factory_linked_service_key_vault.this.name
        type          = "LinkedServiceReference"
      }
      secretName = var.oracle_connection_string_secret_name
    }
  })

  integration_runtime {
    name = var.self_hosted_ir_name
  }
}
