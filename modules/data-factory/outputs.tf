output "data_factory_id" {
  description = "Resource ID of the Data Factory."
  value       = module.adf.resource_id
}

output "data_factory_name" {
  description = "Name of the Data Factory."
  value       = module.adf.name
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = module.adf.system_assigned_mi_principal_id
}

output "shir_integration_runtime_name" {
  description = "Name of the self-hosted integration runtime."
  value       = azurerm_data_factory_integration_runtime_self_hosted.shir.name
}

output "shir_primary_auth_key" {
  description = "Primary authentication key for the SHIR."
  value       = azurerm_data_factory_integration_runtime_self_hosted.shir.primary_authorization_key
  sensitive   = true
}
