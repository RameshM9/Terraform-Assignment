output "id"                      { value = azurerm_log_analytics_workspace.this.id }
output "name"                    { value = azurerm_log_analytics_workspace.this.name }
output "workspace_id"            { value = azurerm_log_analytics_workspace.this.workspace_id } # GUID used by agent
output "primary_shared_key"      { value = azurerm_log_analytics_workspace_shared_keys.keys.primary_shared_key  sensitive = true }
output "location"                { value = azurerm_log_analytics_workspace.this.location }