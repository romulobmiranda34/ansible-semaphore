output "sql_server_fqdn" {
  description = "FQDN do servidor SQL"
  value       = azurerm_mssql_server.main.fully_qualified_domain_name
}

output "database_id" {
  description = "ID do banco de dados"
  value       = azurerm_mssql_database.main.id
}

output "connection_string" {
  description = "String de conexão ADO.NET"
  value       = "Server=tcp:${azurerm_mssql_server.main.fully_qualified_domain_name},1433;Initial Catalog=${var.database_name};Persist Security Info=False;User ID=${var.admin_username};Password=${var.admin_password};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"
  sensitive   = true
}
