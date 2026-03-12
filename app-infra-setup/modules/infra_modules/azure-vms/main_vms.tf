resource "azurerm_public_ip" "public_ip" {
  count               = lower(var.m_create_vm_public_ip) == "yes" ? var.m_vm_count : 0
  name                = "${var.m_vmname}${count.index+1}_public_ip"
  location            = var.m_location
  resource_group_name = var.m_rgname
  allocation_method   = "Dynamic"
  tags                = var.m_tags
}

resource "azurerm_network_interface" "nic" {
  count               = var.m_vm_count
  name                = "${var.m_vmname}${count.index+1}-nic"
  location            = var.m_location
  resource_group_name = var.m_rgname
  tags                = var.m_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.m_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.m_create_vm_public_ip ? azurerm_public_ip.public_ip[count.index].id : ""
  }

  depends_on = [ azurerm_public_ip.public_ip ]
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  count                         = var.m_vm_count
  name                          = "${var.m_vmname}${count.index+1}"
  location                      = var.m_location
  resource_group_name           = var.m_rgname
  network_interface_ids         = [azurerm_network_interface.nic[count.index].id]
  size                          = var.m_vmsize
  disable_password_authentication = false
  admin_username                = var.m_username
  admin_password                = var.m_password
  tags                          = var.m_tags
  os_disk {
    name                 = "${var.m_vmname}${count.index+1}-OsDisk"
    caching              = "ReadWrite"
    storage_account_type = var.m_os_disk_storage_account_type
    disk_size_gb         = var.m_disk_size_gb
  } 
  depends_on = [ azurerm_network_interface.nic ]
}
