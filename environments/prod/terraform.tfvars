# =============================================================================
# Production Environment – terraform.tfvars
# =============================================================================

subscription_id = "22222222-2222-2222-2222-222222222222" # TODO: replace

location     = "eastus2"
environment  = "prod"
project_name = "adfproj"

tags = {
  cost_center = "12345"
  owner       = "data-engineering"
}

# Networking
vnet_address_space = ["10.30.0.0/16"]

subnet_prefixes = {
  snet-private-endpoints = {
    address_prefix                    = "10.30.1.0/24"
    private_endpoint_network_policies = "Enabled"
  }
  snet-shir = {
    address_prefix = "10.30.2.0/24"
  }
}

# Data Factory
data_factory_public_network_enabled = false

# Key Vault
key_vault_sku              = "standard"
key_vault_admin_object_ids = [] # TODO: add Azure AD object IDs

# SHIR VM
shir_vm_node_count     = 2                     # HA: 2 nodes for prod (up to 4)
shir_vm_size           = "Standard_D4s_v5"
shir_vm_admin_username = "azureadmin"

# Storage Account
storage_account_name     = "stadfprojprd01"        # TODO: must be globally unique
storage_account_tier     = "Standard"
storage_replication_type = "GZRS"                   # Geo-zone-redundant for prod

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
sql_server_name        = "sql-adfproj-prd-eus2"           # TODO: must be globally unique
sql_ad_admin_login     = "sqladmin-group"                  # TODO: AD group display name
sql_ad_admin_object_id = "22222222-2222-2222-2222-222222222222" # TODO: AD group object ID
sql_ad_auth_only       = true
sql_database_name      = "sqldb-adfproj-prd"
sql_database_sku       = "GP_Gen5_2"                       # General Purpose for prod
sql_database_max_size_gb    = 250
sql_database_zone_redundant = true                          # Zone redundant for prod

# Linked Services – Oracle
oracle_connection_string_secret_name = "oracle-connection-string"
