resource "azurerm_public_ip" "public_ip" {
  count               = lower(var.m_create_node_public_ip) == "yes" ? var.m_node_count : 0
  name                = "${var.m_nodename}${count.index+1}_public_ip"
  location            = var.m_location
  resource_group_name = var.m_rgname
  allocation_method   = "Static"
  tags                = var.m_tags
}

resource "azurerm_network_interface" "nic" {
  count               = var.m_node_count
  name                = "${var.m_nodename}${count.index+1}-nic-${count.index+1}"
  location            = var.m_location
  resource_group_name = var.m_rgname
  tags                = var.m_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.m_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = lower(var.m_create_node_public_ip) == "yes" ? azurerm_public_ip.public_ip[count.index].id : null
  }

  depends_on = [ azurerm_public_ip.public_ip ]
}

resource "azurerm_linux_virtual_machine" "nodes" {
  count                         = var.m_node_count
  name                          = "${var.m_nodename}${count.index+1}"
  computer_name                 = "${var.m_nodename}${count.index+1}-PC"
  location                      = var.m_location
  resource_group_name           = var.m_rgname
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]
  size                          = var.m_nodesize
  disable_password_authentication = false
  admin_username                = var.m_username
  admin_password                = var.m_password
  tags                          = var.m_tags


  os_disk {
    name                 = "${var.m_nodename}${count.index+1}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.m_os_disk_storage_account_type
    disk_size_gb         = var.m_disk_size_gb
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [var.m_uamiid]
  } 
  depends_on = [ azurerm_network_interface.nic ]
}

resource "azurerm_virtual_machine_extension" "ama_linux" {
  count                       = lower(var.m_associate_azure_monitor) == "yes" ? var.m_node_count : 0
  name                        = "AzureMonitorLinuxAgent"
  virtual_machine_id          = azurerm_linux_virtual_machine.nodes[count.index].id
  publisher                   = "Microsoft.Azure.Monitor"
  type                        = "AzureMonitorLinuxAgent"
  type_handler_version        = "1.0"
  auto_upgrade_minor_version  = true
  automatic_upgrade_enabled   = true
  failure_suppression_enabled = false
  settings = jsonencode({
    authentication = {
      managedIdentity = {
        identifier-name  = "mi_res_id"
        identifier-value = "${var.m_uamiid}"
      }
    }
  })
}

output "node_pub_ip" {
depends_on = [ azurerm_linux_virtual_machine.nodes ]
  value = azurerm_linux_virtual_machine.nodes.*.public_ip_address
  }
output "node_priv_ip" {
depends_on = [ azurerm_linux_virtual_machine.nodes ]
  value = azurerm_linux_virtual_machine.nodes.*.private_ip_address
}


