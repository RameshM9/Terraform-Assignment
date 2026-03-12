# Creating Variables for subnets Module
# Variable Name starts with "m_" whcih indicates module variables

variable "m_subnetname" {
  type = string
  description = "creating subnet name"
}
variable "m_vnetname" {
  type = string
  description = "assigning virtual network name to subnet"
}
variable "m_rgname" {
  type = string
  description = "Name of the ResourceGroup to be assigned to subnet"
}
variable "m_address_prefixes" {
  type = list(string)
  description = "CIDR range to be assigned to subnet"
}
variable "m_network_security_group_id" {
  type = string
  description = "assigning network security group id to subnet"
}