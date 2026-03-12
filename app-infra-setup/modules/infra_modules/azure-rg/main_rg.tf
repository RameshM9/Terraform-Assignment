# Module for creating Resource Group in Azure

resource "azurerm_resource_group" "rg" {
    name        = var.m_rgname
    location    = var.m_location
    tags        = var.m_tags
}

# Exporting output to utilize the same for other resources
output "rg_name" {
  value = azurerm_resource_group.rg.name
}
output "rg_location" {
  value = azurerm_resource_group.rg.location
}
output "rg_id" {
  value = azurerm_resource_group.rg.id
}