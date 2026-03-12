terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.63.0"
    }
  }
  backend "azurerm" {
   # Required all backend variables (resource_group_name,storage_account_name,container_name,tfstatename and accesskey) are pass through Azure-DevOps pipeline. 
   # Find here : Pipelines >> Library >> backendvariables
 }
}

provider "azurerm" {
  features {}
  # use_msi = true
  # client_id = "63f4dd9c-e061-452e-bb49-a47ff029656f"
}
provider "azuread" {
  
}
