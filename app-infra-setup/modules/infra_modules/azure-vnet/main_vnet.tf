# Module for creating Virtual Networks in Azure

resource "azurerm_virtual_network" "vnet" {
  name                = var.m_vnetname
  location            = var.m_location
  resource_group_name = var.m_rgname
  address_space       = var.m_address_space
  tags                = var.m_tags

  }
output "vnetname" {
  value = azurerm_virtual_network.vnet.name
}
output "vnetrg" {
  value = azurerm_virtual_network.vnet.resource_group_name
}
output "vnetid" {
  value = azurerm_virtual_network.vnet.id
}
