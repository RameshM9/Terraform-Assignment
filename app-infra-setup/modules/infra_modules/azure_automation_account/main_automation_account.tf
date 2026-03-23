resource "azurerm_automation_account" "azautomationaccount" {
  name                = var.m_automationaccountname
  location            = var.m_location
  resource_group_name = var.m_resource_group_name
  sku_name            = var.m_sku_name

   identity {
    type = "SystemAssigned"
  }

  tags = {
    Purpose   = "dsc-configuration"
    ManagedBy = "terraform"
  }

}

resource "azurerm_automation_dsc_configuration" "azautodscconfiguration" {
  name                    = "azautodscconfiguration"
  resource_group_name     = m_resource_group_name
  automation_account_name = azurerm_automation_account.azautomationaccount.name
  location                = var.m_location
  # content_embedded        = filebase64(.//WebsiteNgnix.ps1)
  content_embedded        = "configuration test {}"
}
