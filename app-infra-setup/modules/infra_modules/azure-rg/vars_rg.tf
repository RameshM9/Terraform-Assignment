# Creating Variables for Resourcegroup Module
# Variable Name starts with "m_" whcih indicates module variables

variable "m_rgname" {
  type = string
  description = "Name of the ResourceGroup"
}
variable "m_location" {
  type = string
  description = "Location of the ResourceGroup"
}
variable "m_tags" {
  type = map(any)
  description = "Tags the ResourceGroup"
  default = {
    CreatedWith = "Terraform"
    }
}