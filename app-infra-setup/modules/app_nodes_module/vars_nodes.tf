# Creating Variables for Virtual Machine Creation Module
# Variable Name starts with "m_" whcih indicates module variables

variable "m_tags" {
  type = map(any)
  description = "Tags the Resource"
  default = {
    CreatedWith = "Terraform"
    }
}
variable "m_create_node_public_ip" {
  type = string
  description = "create public IP only when said yes or skip creating"
  default = "no"
}
variable "m_location" {
  type = string
  description = "Location of the ResourceGroup"
}
variable "m_rgname" {
  type = string
  description = "Name of the ResourceGroup"
}
variable m_subnet_id {
  description = "Specifies the resource id of the subnet hosting the virtual machine"
  type        = string
}
variable "m_node_count" {
  type = number
  description = "Number of the Virtual Machines to be created"
}
variable "m_nodename" {
  type = string
  description = "Name of the Virtual Machines"
}

variable m_nodesize {
  description = "Specifies the size of the virtual machine"
  type = string
  default = "Standard_B1ls"
}
variable m_username {
  description = "Specifies the username of the virtual machine"
  type        = string
}
variable m_password {
  description = "Specifies the password of the virtual machine"
  type        = string
  sensitive = true
}
variable "m_os_disk_storage_account_type" {
  description = "Specifies the storage account type of the os disk of the virtual machine"
  default     = "Standard_LRS"
  type        = string
}

variable "m_uamiid" {
  type = string
  description = "ID of the User Assigned Managed Identity"
}

