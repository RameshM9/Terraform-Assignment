# Creating Variables for Network Security Group Module
# Variable Name starts with "m_" whcih indicates module variables

variable "m_tags" {
  type = map(any)
  description = "Tags the Resource"
  default = {
    CreatedWith = "Terraform"
    }
}
variable "m_nsgname" {
  type = string
  description = "Name of the Virtual Network"
}
variable "m_location" {
  type = string
  description = "Location of the ResourceGroup"
}
variable "m_rgname" {
  type = string
  description = "Name of the ResourceGroup"
}

variable "m_nsg_rules" {
  type        = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_port_ranges         = list(any)
    destination_port_ranges    = list(any)
    source_address_prefix      = string
    destination_address_prefix = string
    source_address_prefixes      = list(any)
    destination_address_prefixes = list(any)
    source_application_security_group_ids = list(any)
    destination_application_security_group_ids = list(any)
  }))
  default     = []
  description = "The values for each NSG rules"
}