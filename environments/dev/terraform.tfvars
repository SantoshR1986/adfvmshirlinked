# =============================================================================
# Dev Environment – terraform.tfvars
# Values that are safe to commit to source control.
# =============================================================================

subscription_id = "00000000-0000-0000-0000-000000000000" # TODO: replace

location     = "eastus2"
environment  = "dev"
project_name = "adfproj"

tags = {
  cost_center = "12345"
  owner       = "data-engineering"
}

# Networking
vnet_address_space = ["10.10.0.0/16"]

subnet_prefixes = {
  snet-private-endpoints = {
    address_prefix                    = "10.10.1.0/24"
    private_endpoint_network_policies = "Enabled"
  }
  snet-shir = {
    address_prefix = "10.10.2.0/24"
  }
}

# Data Factory
data_factory_public_network_enabled = false

# Key Vault
key_vault_sku              = "standard"
key_vault_admin_object_ids = [] # TODO: add Azure AD object IDs

# SHIR VM
shir_vm_size           = "Standard_D2s_v5"
shir_vm_admin_username = "azureadmin"

# Storage Account
storage_account_name     = "stadfprojdev01"      # TODO: must be globally unique
storage_account_tier     = "Standard"
storage_replication_type = "LRS"                  # LRS for dev cost savings

storage_containers = {
  raw = {
    access_type = "private"
  }
  curated = {
    access_type = "private"
  }
  staging = {
    access_type = "private"
  }
}

# Azure SQL Server & Database
sql_server_name        = "sql-adfproj-dev-eus2"           # TODO: must be globally unique
sql_ad_admin_login     = "sqladmin-group"                  # TODO: AD group display name
sql_ad_admin_object_id = "00000000-0000-0000-0000-000000000000" # TODO: AD group object ID
sql_ad_auth_only       = true
sql_database_name      = "sqldb-adfproj-dev"
sql_database_sku       = "S0"
sql_database_max_size_gb    = 20
sql_database_zone_redundant = false

# Linked Services – Oracle
oracle_connection_string_secret_name = "oracle-connection-string"
