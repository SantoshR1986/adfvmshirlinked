output "sql_server_id" {
  description = "Resource ID of the Azure SQL Server."
  value       = module.sql_server.resource_id
}

output "sql_server_name" {
  description = "Name of the Azure SQL Server."
  value       = module.sql_server.name
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the Azure SQL Server."
  value       = module.sql_server.resource.fully_qualified_domain_name
}

output "sql_server_identity_principal_id" {
  description = "Principal ID of the SQL Server system-assigned managed identity."
  value       = module.sql_server.system_assigned_mi_principal_id
}

output "database_id" {
  description = "Resource ID of the SQL database."
  value       = azurerm_mssql_database.this.id
}

output "database_name" {
  description = "Name of the SQL database."
  value       = azurerm_mssql_database.this.name
}
