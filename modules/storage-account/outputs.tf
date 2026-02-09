output "storage_account_id" {
  description = "Resource ID of the storage account."
  value       = module.storage_account.resource_id
}

output "storage_account_name" {
  description = "Name of the storage account."
  value       = module.storage_account.name
}

output "primary_blob_endpoint" {
  description = "Primary blob service endpoint URL."
  value       = module.storage_account.resource.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "Hostname of the primary blob endpoint."
  value       = module.storage_account.resource.primary_blob_host
}
