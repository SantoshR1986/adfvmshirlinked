# =============================================================================
# Azure SQL Server + Database – AVM Module
# =============================================================================
data "azurerm_client_config" "current" {}

module "sql_server" {
  source  = "Azure/avm-res-sql-server/azurerm"
  version = "~> 0.2"

  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  server_version                = "12.0"
  public_network_access_enabled = false

  managed_identities = {
    system_assigned = true
  }

  # Azure AD-only authentication (no SQL auth password in code)
  azuread_administrator = {
    login_username              = var.sql_ad_admin_login
    object_id                   = var.sql_ad_admin_object_id
    azuread_authentication_only = var.sql_ad_auth_only
  }

  tags = var.tags
}

# =============================================================================
# SQL Database
# =============================================================================
resource "azurerm_mssql_database" "this" {
  name      = var.database_name
  server_id = module.sql_server.resource_id

  sku_name     = var.database_sku
  max_size_gb  = var.database_max_size_gb
  collation    = var.database_collation
  zone_redundant = var.database_zone_redundant

  short_term_retention_policy {
    retention_days = var.short_term_retention_days
  }

  long_term_retention_policy {
    weekly_retention  = var.ltr_weekly_retention
    monthly_retention = var.ltr_monthly_retention
  }

  tags = var.tags
}

# =============================================================================
# Role Assignment – ADF Managed Identity → SQL Server Contributor
# This allows ADF to connect via managed identity. You must also run
# CREATE USER [adf-name] FROM EXTERNAL PROVIDER; in the database.
# =============================================================================
resource "azurerm_role_assignment" "adf_sql_contributor" {
  scope                = module.sql_server.resource_id
  role_definition_name = "Contributor"
  principal_id         = var.adf_identity_principal_id
}
