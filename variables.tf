# -----------------------------------------------------------------------------
# General
# -----------------------------------------------------------------------------
variable "subscription_id" {
  description = "Azure subscription ID."
  type        = string
}

variable "location" {
  description = "Azure region for all resources."
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Short project/workload name used in resource naming."
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Resource Group
# -----------------------------------------------------------------------------
variable "resource_group_name" {
  description = "Name of the resource group. If empty one will be generated."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
}

variable "subnet_prefixes" {
  description = "Map of subnet name to address prefix."
  type = map(object({
    address_prefix                    = string
    private_endpoint_network_policies = optional(string, "Enabled")
  }))
}

variable "private_dns_zone_ids" {
  description = "Optional map of existing private DNS zone resource IDs to link. Keys: datafactory, vault, blob, sqlServer."
  type        = map(string)
  default     = {}
}

# -----------------------------------------------------------------------------
# Data Factory
# -----------------------------------------------------------------------------
variable "data_factory_public_network_enabled" {
  description = "Whether the ADF public endpoint is accessible."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
variable "key_vault_sku" {
  description = "Key Vault SKU (standard or premium)."
  type        = string
  default     = "standard"
}

variable "key_vault_admin_object_ids" {
  description = "Azure AD object IDs that receive Key Vault Administrator role."
  type        = list(string)
  default     = []
}

# -----------------------------------------------------------------------------
# SHIR VM
# -----------------------------------------------------------------------------
variable "shir_vm_size" {
  description = "Azure VM size for the self-hosted integration runtime host."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "shir_vm_admin_username" {
  description = "Local admin username for the SHIR VM."
  type        = string
  default     = "azureadmin"
}

variable "shir_vm_admin_password" {
  description = "Local admin password for the SHIR VM. Stored in Key Vault."
  type        = string
  sensitive   = true
}

variable "shir_vm_image" {
  description = "Source image for the SHIR Windows VM."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}

# -----------------------------------------------------------------------------
# Storage Account
# -----------------------------------------------------------------------------
variable "storage_account_name" {
  description = "Globally unique storage account name (3-24 chars, lowercase alphanumeric)."
  type        = string
}

variable "storage_account_tier" {
  description = "Storage account tier (Standard or Premium)."
  type        = string
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Replication type (LRS, GRS, ZRS, GZRS, RA-GRS, RA-GZRS)."
  type        = string
  default     = "GRS"
}

variable "storage_containers" {
  description = "Map of blob containers to create."
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

# -----------------------------------------------------------------------------
# Azure SQL Server & Database
# -----------------------------------------------------------------------------
variable "sql_server_name" {
  description = "Globally unique Azure SQL Server name."
  type        = string
}

variable "sql_ad_admin_login" {
  description = "Azure AD admin display name for SQL Server."
  type        = string
}

variable "sql_ad_admin_object_id" {
  description = "Azure AD object ID of the SQL Server administrator."
  type        = string
}

variable "sql_ad_auth_only" {
  description = "Enforce Azure AD-only authentication on SQL Server."
  type        = bool
  default     = true
}

variable "sql_database_name" {
  description = "Name of the SQL database."
  type        = string
}

variable "sql_database_sku" {
  description = "SQL Database SKU (e.g. S0, GP_S_Gen5_2, GP_Gen5_2)."
  type        = string
  default     = "S0"
}

variable "sql_database_max_size_gb" {
  description = "Maximum database size in GB."
  type        = number
  default     = 50
}

variable "sql_database_zone_redundant" {
  description = "Enable zone redundancy for the SQL database."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Linked Service – On-prem Oracle
# -----------------------------------------------------------------------------
variable "oracle_connection_string_secret_name" {
  description = "Key Vault secret name that holds the Oracle connection string."
  type        = string
  default     = "oracle-connection-string"
}

variable "oracle_connection_string" {
  description = "Oracle on-prem connection string value. Stored in Key Vault."
  type        = string
  sensitive   = true
  default     = ""
}
