# Creating Variables for Virtual Network Module
# Variable Name starts with "m_" whcih indicates module variables

variable "m_tags" {
  type = map(any)
  description = "Tags the Resource"
  default = {
    CreatedWith = "Terraform"
    }
}
variable "m_vnetname" {
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
variable "m_address_space" {
  type = list(string)
  description = "Name of the ResourceGroup"
}
