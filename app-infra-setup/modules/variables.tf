# NOTE : These variables are common for all the modules.

variable "tags" {
  type = map(any)
  description = "Tags the ResourceGroup"
  default = {
    CreatedWith = "Terraform"
    }
}
variable "app_prefix" {
  type = string
  description = "Organization Name Prefix for the Resources"
}
variable "env_prefix" {
  type = string
  description = "Environment prefix in the names of resources"
}
variable "rg_names" {  
  type = list(object({
    rg_name_sufix = string
    location = string
    location_prefix = string
  }))    
  description = "names of resourcegroups to be created and assigned in the specified location/region"
}
variable "virtualnetworks" {
  type = list(object({
    vnetname = string
    address = string
    rg_index = number
  }))
}
variable "subnets" {
  type = list(object({
    snetname = string
     address = string
     vnet_index = number
     nsg_index = number
  }))
}

variable "nsg_with_rules" {
  type = map(object({
    rg_index = number
    rules = list(object({
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
    
  }))
  description = "The values for each NSG rules"
}
 
 
variable "webapp_dev_vnet_name" {
  type = string
  description = "provide the name of existing vnet which will pull the data and can be used to peer with newly creating vnet"
}
variable "webapp_dev_vnet-rg_name" {
  type = string
  description = "provide the resourece group name of existing vnet which will pull the data and can be used to peer with newly creating vnet"
}
 
variable "create_virtual_machines" {
  type = string
  description = "apply this module only when said yes or skip creating"
  default = "no"
}

variable "existing_uami" {
  type = object({
    name = string
    rg = string
  })
  description = "Details of existing User Assigned Managed Identity"
}
 
variable "associate_dcr_to_all_nodes" {
  type = string
  description = "For Associating data collection rule if said yes else skip the same"
  default = "yes"
}


############################# SYSTEM CONFIG  #################################
variable "vm_details" {
  type = map(object({
    rg_index = number
    subnet_index = number
    vm_count = number
    create_vm_public_ip = string
    size = string
    username = string
    password = string
    disk_type = string
    disk_size_gb = number
    os_image = map(string)
  }))
}


variable "spm_prefix" {
  type = string
  description = "apply this module only when said yes or skip creating"
  default = "spm-prefix"
}

variable "vm_os_type" {
  type = string
  description = "apply this module only when said yes or skip creating"
  default = "Linux"
}

variable "suc_start_time_utc" {
  type = string
  description = "apply this module only when said yes or skip creating"
  default = "2026-03-13T20:30:00Z"
}
