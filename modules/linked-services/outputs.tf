output "linked_service_keyvault_name" {
  description = "Name of the Key Vault linked service."
  value       = azurerm_data_factory_linked_service_key_vault.this.name
}

output "linked_service_blob_name" {
  description = "Name of the Blob Storage linked service."
  value       = azurerm_data_factory_linked_service_azure_blob_storage.this.name
}

output "linked_service_sql_name" {
  description = "Name of the Azure SQL linked service."
  value       = azurerm_data_factory_linked_service_azure_sql_database.this.name
}

output "linked_service_oracle_name" {
  description = "Name of the Oracle linked service."
  value       = azurerm_data_factory_linked_custom_service.oracle.name
}
