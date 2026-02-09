variable "data_factory_id" {
  description = "Resource ID of the Data Factory."
  type        = string
}

variable "data_factory_name" {
  description = "Name of the Data Factory."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault."
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault."
  type        = string
}

variable "self_hosted_ir_name" {
  description = "Name of the self-hosted integration runtime for on-prem connections."
  type        = string
}

# Blob Storage
variable "blob_storage_endpoint" {
  description = "Primary blob service endpoint URL of the storage account."
  type        = string
}

# Azure SQL
variable "azure_sql_server_fqdn" {
  description = "FQDN of the Azure SQL Server."
  type        = string
}

variable "azure_sql_database_name" {
  description = "Database name on the Azure SQL Server."
  type        = string
}

# Oracle
variable "oracle_connection_string_secret_name" {
  description = "Key Vault secret name holding the Oracle connection string."
  type        = string
}
