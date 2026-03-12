# Module for creating Network security group and security rules in Azure

resource "azurerm_network_security_group" "nsg" {
  name                = var.m_nsgname
  location            = var.m_location
  resource_group_name = var.m_rgname
  tags                = var.m_tags

  dynamic "security_rule" {
    for_each = try(var.m_nsg_rules,[])
    content {
      name                                       = try(security_rule.value.name, null)
      priority                                   = try(security_rule.value.priority, null)
      direction                                  = try(security_rule.value.direction, null)
      access                                     = try(security_rule.value.access, null)
      protocol                                   = try(security_rule.value.protocol, null)
      source_port_range                          = try(security_rule.value.source_port_range, null)
      source_port_ranges                         = try(security_rule.value.source_port_ranges, null)
      destination_port_range                     = try(security_rule.value.destination_port_range, null)
      destination_port_ranges                    = try(security_rule.value.destination_port_ranges, null)
      source_address_prefix                      = try(security_rule.value.source_address_prefix, null)
      source_address_prefixes                    = try(security_rule.value.source_address_prefixes, null)
      destination_address_prefix                 = try(security_rule.value.destination_address_prefix, null)
      destination_address_prefixes               = try(security_rule.value.destination_address_prefixes, null)
      source_application_security_group_ids      = try(security_rule.value.source_application_security_group_ids, null)
      destination_application_security_group_ids = try(security_rule.value.destination_application_security_group_ids, null)
    }
  }
}

# Exporting output to utilize the same for other resources

output "nsg_id" {
  value = azurerm_network_security_group.nsg.id
}
