# =============================================================================
# Individual Resource Outputs
# =============================================================================
output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "data_factory_id" {
  description = "Resource ID of the Data Factory."
  value       = module.data_factory.data_factory_id
}

output "data_factory_name" {
  description = "Name of the Data Factory."
  value       = module.data_factory.data_factory_name
}

output "data_factory_identity_principal_id" {
  description = "Principal ID of the Data Factory system-assigned managed identity."
  value       = module.data_factory.identity_principal_id
}

output "key_vault_id" {
  description = "Resource ID of the Key Vault."
  value       = module.key_vault.key_vault_id
}

output "key_vault_uri" {
  description = "URI of the Key Vault."
  value       = module.key_vault.key_vault_uri
}

output "storage_account_id" {
  description = "Resource ID of the Storage Account."
  value       = module.storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Name of the Storage Account."
  value       = module.storage_account.storage_account_name
}

output "storage_primary_blob_endpoint" {
  description = "Primary blob endpoint of the Storage Account."
  value       = module.storage_account.primary_blob_endpoint
}

output "sql_server_id" {
  description = "Resource ID of the Azure SQL Server."
  value       = module.azure_sql.sql_server_id
}

output "sql_server_fqdn" {
  description = "FQDN of the Azure SQL Server."
  value       = module.azure_sql.sql_server_fqdn
}

output "sql_database_name" {
  description = "Name of the SQL Database."
  value       = module.azure_sql.database_name
}

output "shir_vm_name" {
  description = "Name of the Self-Hosted Integration Runtime VM."
  value       = module.shir_vm.vm_name
}

output "shir_vm_private_ip" {
  description = "Private IP address of the SHIR VM."
  value       = module.shir_vm.private_ip_address
}

output "shir_integration_runtime_name" {
  description = "Name of the SHIR integration runtime in ADF."
  value       = module.data_factory.shir_integration_runtime_name
}

output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = module.networking.vnet_id
}

output "private_endpoint_ids" {
  description = "Map of private endpoint resource IDs."
  value       = module.private_endpoints.private_endpoint_ids
}

# =============================================================================
# Linked Service Names
# =============================================================================
output "linked_service_names" {
  description = "Map of all ADF linked service names."
  value = {
    key_vault = module.linked_services.linked_service_keyvault_name
    blob      = module.linked_services.linked_service_blob_name
    sql       = module.linked_services.linked_service_sql_name
    oracle    = module.linked_services.linked_service_oracle_name
  }
}

# =============================================================================
# Relationship Map – complete wiring between every resource
# =============================================================================
output "resource_relationship_map" {
  description = <<-EOT
    Complete relationship map showing how every resource connects.
    Use `terraform output -json resource_relationship_map` for machine-readable format.
  EOT
  value = {
    data_factory = {
      resource_id   = module.data_factory.data_factory_id
      resource_name = module.data_factory.data_factory_name
      identity = {
        type         = "SystemAssigned"
        principal_id = module.data_factory.identity_principal_id
        rbac_roles = {
          storage_blob_data_contributor = module.storage_account.storage_account_id
          sql_server_contributor        = module.azure_sql.sql_server_id
        }
      }
      integration_runtimes = {
        self_hosted = {
          name          = module.data_factory.shir_integration_runtime_name
          host_vm       = module.shir_vm.vm_name
          host_vm_ip    = module.shir_vm.private_ip_address
          auth_key_in   = "${module.key_vault.key_vault_name}/secrets/shir-auth-key"
        }
      }
      linked_services = {
        key_vault = {
          name        = module.linked_services.linked_service_keyvault_name
          target      = module.key_vault.key_vault_name
          target_id   = module.key_vault.key_vault_id
          auth_method = "managed_identity"
        }
        blob_storage = {
          name        = module.linked_services.linked_service_blob_name
          target      = module.storage_account.storage_account_name
          target_id   = module.storage_account.storage_account_id
          endpoint    = module.storage_account.primary_blob_endpoint
          auth_method = "managed_identity"
        }
        azure_sql = {
          name        = module.linked_services.linked_service_sql_name
          target      = "${module.azure_sql.sql_server_name}/${module.azure_sql.database_name}"
          server_id   = module.azure_sql.sql_server_id
          database_id = module.azure_sql.database_id
          fqdn        = module.azure_sql.sql_server_fqdn
          auth_method = "managed_identity"
        }
        oracle_onprem = {
          name                    = module.linked_services.linked_service_oracle_name
          auth_method             = "key_vault_secret"
          secret_reference        = "${module.key_vault.key_vault_name}/secrets/${var.oracle_connection_string_secret_name}"
          integration_runtime     = module.data_factory.shir_integration_runtime_name
          connection_path         = "ADF → SHIR VM → on-prem Oracle"
        }
      }
      private_endpoint = {
        name                 = "pe-adf-${local.name_prefix}"
        private_dns_zone     = "privatelink.datafactory.azure.net"
        subnet               = local.pe_subnet_name
      }
    }

    key_vault = {
      resource_id   = module.key_vault.key_vault_id
      resource_name = module.key_vault.key_vault_name
      uri           = module.key_vault.key_vault_uri
      secrets_stored = [
        "shir-auth-key",
        "shir-vm-admin-password",
        var.oracle_connection_string_secret_name,
      ]
      consumed_by = {
        data_factory_linked_service = module.linked_services.linked_service_keyvault_name
        shir_vm_password            = module.shir_vm.vm_name
      }
      private_endpoint = {
        name             = "pe-kv-${local.name_prefix}"
        private_dns_zone = "privatelink.vaultcore.azure.net"
        subnet           = local.pe_subnet_name
      }
    }

    storage_account = {
      resource_id    = module.storage_account.storage_account_id
      resource_name  = module.storage_account.storage_account_name
      blob_endpoint  = module.storage_account.primary_blob_endpoint
      accessed_by = {
        adf_linked_service = module.linked_services.linked_service_blob_name
        adf_identity       = module.data_factory.identity_principal_id
        rbac_role          = "Storage Blob Data Contributor"
      }
      private_endpoint = {
        name             = "pe-blob-${local.name_prefix}"
        private_dns_zone = "privatelink.blob.core.windows.net"
        subnet           = local.pe_subnet_name
      }
    }

    azure_sql = {
      server_id     = module.azure_sql.sql_server_id
      server_name   = module.azure_sql.sql_server_name
      server_fqdn   = module.azure_sql.sql_server_fqdn
      database_id   = module.azure_sql.database_id
      database_name = module.azure_sql.database_name
      accessed_by = {
        adf_linked_service = module.linked_services.linked_service_sql_name
        adf_identity       = module.data_factory.identity_principal_id
        rbac_role          = "Contributor"
      }
      private_endpoint = {
        name             = "pe-sql-${local.name_prefix}"
        private_dns_zone = "privatelink.database.windows.net"
        subnet           = local.pe_subnet_name
      }
    }

    shir_vm = {
      vm_name         = module.shir_vm.vm_name
      private_ip      = module.shir_vm.private_ip_address
      subnet          = local.shir_subnet_name
      registered_to   = module.data_factory.shir_integration_runtime_name
      connects_to     = ["on-prem Oracle via ls-oracle-onprem"]
      credentials_in  = "${module.key_vault.key_vault_name}/secrets/shir-vm-admin-password"
    }

    networking = {
      vnet_id = module.networking.vnet_id
      subnets = module.networking.subnet_ids
      private_dns_zones = {
        datafactory = "privatelink.datafactory.azure.net"
        vault       = "privatelink.vaultcore.azure.net"
        blob        = "privatelink.blob.core.windows.net"
        sqlServer   = "privatelink.database.windows.net"
      }
      private_endpoints = module.private_endpoints.private_endpoint_ids
    }
  }
}

# =============================================================================
# Data Flow Summary – human-readable connectivity paths
# =============================================================================
output "data_flow_paths" {
  description = "Human-readable data flow paths through the architecture."
  value = {
    blob_pipeline   = "ADF (${module.data_factory.data_factory_name}) → [managed identity] → PE (pe-blob) → Storage (${module.storage_account.storage_account_name})"
    sql_pipeline    = "ADF (${module.data_factory.data_factory_name}) → [managed identity] → PE (pe-sql) → SQL Server (${module.azure_sql.sql_server_name}/${module.azure_sql.database_name})"
    oracle_pipeline = "ADF (${module.data_factory.data_factory_name}) → SHIR (${module.data_factory.shir_integration_runtime_name}) → VM (${module.shir_vm.vm_name} @ ${module.shir_vm.private_ip_address}) → on-prem Oracle [secret from ${module.key_vault.key_vault_name}]"
    secret_access   = "ADF (${module.data_factory.data_factory_name}) → [managed identity] → PE (pe-kv) → Key Vault (${module.key_vault.key_vault_name})"
  }
}

# =============================================================================
# Security Summary – RBAC & auth method per connection
# =============================================================================
output "security_summary" {
  description = "Authentication and authorization methods for every connection."
  value = {
    adf_to_blob = {
      auth_method     = "System-Assigned Managed Identity"
      rbac_role       = "Storage Blob Data Contributor"
      scope           = module.storage_account.storage_account_id
      network_path    = "Private Endpoint → privatelink.blob.core.windows.net"
    }
    adf_to_sql = {
      auth_method     = "System-Assigned Managed Identity"
      rbac_role       = "Contributor (+ CREATE USER FROM EXTERNAL PROVIDER in DB)"
      scope           = module.azure_sql.sql_server_id
      network_path    = "Private Endpoint → privatelink.database.windows.net"
    }
    adf_to_keyvault = {
      auth_method     = "System-Assigned Managed Identity"
      rbac_role       = "Key Vault Secrets User (via ADF linked service)"
      scope           = module.key_vault.key_vault_id
      network_path    = "Private Endpoint → privatelink.vaultcore.azure.net"
    }
    adf_to_oracle = {
      auth_method     = "Connection string from Key Vault secret"
      secret_name     = var.oracle_connection_string_secret_name
      runtime         = "Self-Hosted Integration Runtime"
      network_path    = "SHIR VM (private subnet) → corporate network → on-prem Oracle"
    }
    shir_vm_to_adf = {
      auth_method     = "SHIR authorization key"
      key_stored_in   = "${module.key_vault.key_vault_name}/secrets/shir-auth-key"
    }
  }
}
