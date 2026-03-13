resource "azurerm_log_analytics_workspace" "this" {
  name                = var.m_automationaccountname
  location            = var.m_location
  resource_group_name = var.m_rgname
  sku                 = var.m_sku
  retention_in_days   = var.m_retention_days
}

# Keys used to onboard VM agents
resource "azurerm_log_analytics_workspace_shared_keys" "keys" {
  resource_group_name = var.m_rgname
  workspace_id        = azurerm_log_analytics_workspace.this.id
}