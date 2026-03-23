output "id"   { value = azurerm_automation_account.azautomationaccount.id }
output "name" { value = azurerm_automation_account.azautomationaccount.name }

output "dsc_configuration_name" { value = azurerm_automation_dsc_configuration.azautodscconfiguration.name }
output "dsc_configuration_id" { value = azurerm_automation_dsc_configuration.azautodscconfiguration.id }