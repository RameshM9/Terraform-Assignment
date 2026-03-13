resource "azurerm_automation_account" "this" {
  name                = var.m_automationaccountname
  location            = var.m_location
  resource_group_name = var.m_location
  sku_name            = var.m_sku_name
}
