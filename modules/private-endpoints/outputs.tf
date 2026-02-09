output "private_endpoint_ids" {
  description = "Map of private endpoint resource IDs."
  value       = { for k, v in module.private_endpoint : k => v.resource_id }
}
