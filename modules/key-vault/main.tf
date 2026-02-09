# =============================================================================
# Azure Key Vault – AVM Module
# =============================================================================
data "azurerm_client_config" "current" {}

module "key_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.9"

  name                = "kv-${var.name_prefix}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                        = var.sku
  public_network_access_enabled   = false
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  # RBAC-based access (recommended over access policies)
  enable_rbac_authorization = true

  tags = var.tags
}

# =============================================================================
# Key Vault Administrator role for specified principals
# =============================================================================
resource "azurerm_role_assignment" "kv_admin" {
  for_each = toset(var.admin_object_ids)

  scope                = module.key_vault.resource_id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

# =============================================================================
# Key Vault Secrets User role for deploying identity (Terraform SP)
# =============================================================================
resource "azurerm_role_assignment" "kv_secrets_deployer" {
  scope                = module.key_vault.resource_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

# =============================================================================
# Secrets
# =============================================================================
resource "azurerm_key_vault_secret" "secrets" {
  for_each = { for k, v in var.secrets : k => v if v != "" }

  name         = each.key
  value        = each.value
  key_vault_id = module.key_vault.resource_id

  depends_on = [azurerm_role_assignment.kv_secrets_deployer]
}
