# Module for creating Subnets in Azure

resource "azurerm_subnet" "sub_name" {

  name                                           = var.m_subnetname
  virtual_network_name                           = var.m_vnetname
  resource_group_name                            = var.m_rgname
  address_prefixes                               = var.m_address_prefixes
  
}
resource "azurerm_subnet_network_security_group_association" "nsgsubnetassociation" {
  subnet_id                 = azurerm_subnet.sub_name.id
  network_security_group_id = var.m_network_security_group_id
}
output "subnet_id" {
  value = azurerm_subnet.sub_name.id
}