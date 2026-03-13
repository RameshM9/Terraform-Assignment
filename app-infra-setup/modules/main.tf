
# NOTE : Variable Name which starts with "m_" whcih indicates module variables

# Module Resource Group
module "rg" {
  source = "./modules/infra_modules/azure-rg"
  count = length(var.rg_names)
  m_rgname = "${var.app_prefix}-${var.rg_names[count.index].location_prefix}-${var.env_prefix}-${var.rg_names[count.index].rg_name_sufix}-${count.index+1}"
  m_location = var.rg_names[count.index].location
  m_tags = var.tags
}

# Module Network Security Group
module "nsg" {
  source = "./modules/infra_modules/azure-nsg"
  count = length(var.nsg_with_rules)
  m_nsgname = "${var.app_prefix}-${var.rg_names[values(var.nsg_with_rules)[count.index].rg_index].location_prefix}-${var.env_prefix}-${keys(var.nsg_with_rules)[count.index]}-${count.index+1}"
  m_rgname = module.rg[values(var.nsg_with_rules)[count.index].rg_index].rg_name
  m_location = module.rg[values(var.nsg_with_rules)[count.index].rg_index].rg_location
  m_tags = var.tags

    # Security rules
          m_nsg_rules = values(var.nsg_with_rules)[count.index].rules
  
   depends_on = [ module.rg.rg_name ]
}

# Module Virtual Network
module "vnet" {
  source = "./modules/infra_modules/azure-vnet"
  count = length(var.virtualnetworks)
  m_vnetname = "${var.app_prefix}-${var.rg_names[var.virtualnetworks[count.index].rg_index].location_prefix}-${var.env_prefix}-${var.virtualnetworks[count.index].vnetname}-${count.index+1}"
  m_rgname = module.rg[var.virtualnetworks[count.index].rg_index].rg_name
  m_location = module.rg[var.virtualnetworks[count.index].rg_index].rg_location
  m_address_space = ["${var.virtualnetworks[count.index].address}"]
  m_tags = var.tags

depends_on = [module.rg.rg_name]
}

# Module Subnet
module "snet" {
  source = "./modules/infra_modules/azure-subnet"
  count = length(var.subnets)
  m_subnetname = "${var.app_prefix}-${var.rg_names[var.virtualnetworks[count.index].rg_index].location_prefix}-${var.env_prefix}-${var.subnets[count.index].snetname}-${count.index+1}"
  m_vnetname = module.vnet[var.subnets[count.index].vnet_index].vnetname
  m_rgname = module.vnet[var.subnets[count.index].vnet_index].vnetrg
  m_address_prefixes = ["${var.subnets[count.index].address}"]
  m_network_security_group_id = module.nsg[var.subnets[count.index].nsg_index].nsg_id

depends_on = [ module.vnet.vnetname, module.nsg.nsg_id ]
}


# Module Virtual_Networks_Peering

data "azurerm_virtual_network" "dev_vnet" {
  name                 = var.webapp_dev_vnet_name
  resource_group_name  = var.webapp_dev_vnet-rg_name
}

data "azurerm_subnet" "project_subnets" {
  for_each            = toset(data.azurerm_virtual_network.dev_vnet.subnets)
  name                 = each.value
  virtual_network_name = "${data.azurerm_virtual_network.dev_vnet.name}"
  resource_group_name  = "${data.azurerm_virtual_network.dev_vnet.resource_group_name}"
}

 

# Module for Creating Nodes

data "azurerm_user_assigned_identity" "uami" {
  name                = var.existing_uami.name 
  resource_group_name = var.existing_uami.rg
} 

# Module Virtual_Machine

############################
# Linux VM with NGINX via cloud-init
############################
locals {
  cloud_init = <<-EOF
    #!/bin/bash
    set -e
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y nginx
    systemctl enable nginx
    systemctl restart nginx

    # Simple landing page
    cat >/var/www/html/index.html <<'HTML'
    <html>
      <head><title>NGINX on Azure</title></head>
      <body style="font-family: Arial; margin: 40px;">
        <h1>NGINX is running</h1>
        <p>Deployed via Terraform & cloud-init.</p>
      </body>
    </html>
    HTML
  EOF
}

module "vms" {
  source = "./modules/infra_modules/azure-vms"
  count =  lower(var.create_virtual_machines) == "yes" ? length(var.vm_details) : 0
  m_create_vm_public_ip = values(var.vm_details)[count.index].create_vm_public_ip
  m_subnet_id = module.snet[values(var.vm_details)[count.index].subnet_index].subnet_id
  m_vm_count = values(var.vm_details)[count.index].vm_count
  m_vmname = "${var.app_prefix}${var.rg_names[values(var.vm_details)[count.index].rg_index].location_prefix}${var.env_prefix}${keys(var.vm_details)[count.index]}"
  m_location = module.rg[values(var.vm_details)[count.index].rg_index].rg_location
  m_rgname = module.rg[values(var.vm_details)[count.index].rg_index].rg_name
  m_vmsize = values(var.vm_details)[count.index].size
  m_username = values(var.vm_details)[count.index].username
  m_password = values(var.vm_details)[count.index].password
  m_os_disk_storage_account_type = values(var.vm_details)[count.index].disk_type
  m_disk_size_gb = values(var.vm_details)[count.index].disk_size_gb
  m_tags = var.tags
  m_os_disk_image = values(var.vm_details)[count.index].os_image

  depends_on = [ module.snet ]
}

  # cloud-init (must be base64-encoded)
  custom_data = base64encode(local.cloud_init)


output "WEBSERVER_Public_IPs" {
  value = lower(var.node_details["WEBSERVER"].create_node_public_ip) == "yes" ? module.nodes["WEBSERVER"].node_pub_ip : ["Public IP is not assigned to this node"]
}

output "WEBSERVER_Private_IPs" {
  value = var.node_details["WEBSERVER"].node_count > 0 ? module.nodes["WEBSERVER"].node_priv_ip : ["Private IP is not assigned [or] No Node is Created"]
}

#################### System Patch Management ############################

# -------------------
# Inputs (see variables.tf for all)
# -------------------
# data "azurerm_resource_group" "rg" {
#   name = var.resource_group_name
# }

# Existing VM to onboard to Update Management
data "azurerm_virtual_machine" "vm" {
  name                = var.vm_name
  resource_group_name = var.m_rgname
}

# -------------------
# Modules
# -------------------
module "la" {
  source         = "./modules/log_analytics"
  name           = "${var.prefix}-law"
  location       = data.azurerm_resource_group.rg.location
  resource_group = data.azurerm_resource_group.rg.name
}

module "aa" {
  source         = "./modules/automation_account"
  name           = "${var.prefix}-aa"
  location       = data.azurerm_resource_group.rg.location
  resource_group = data.azurerm_resource_group.rg.name
}

module "um" {
  source                  = "./modules/update_management"
  resource_group          = data.azurerm_resource_group.rg.name
  location                = data.azurerm_resource_group.rg.location
  automation_account_id   = module.aa.id
  automation_account_name = module.aa.name
  workspace_id            = module.la.id
  workspace_name          = module.la.name

  suc_name         = "${var.prefix}-weekly-suc"
  os_type          = var.vm_os_type                 # "Windows" or "Linux"
  azure_vm_ids     = [data.azurerm_virtual_machine.vm.id]

  # Schedule: weekly Saturday 02:00 IST (Fri 20:30 UTC). Adjust as needed.
  start_time_utc   = var.suc_start_time_utc         # e.g., "2026-03-13T20:30:00Z"
  time_zone        = "India Standard Time"
  week_days        = ["Saturday"]
  duration_iso     = "PT2H"
  reboot_setting   = "IfRequired"
}

# -------------------
# Onboard VM to Log Analytics (agent extension)
# -------------------

# WINDOWS VM: MicrosoftMonitoringAgent
resource "azurerm_virtual_machine_extension" "mma_windows" {
  count                       = var.vm_os_type == "Windows" ? 1 : 0
  name                        = "MicrosoftMonitoringAgent"
  virtual_machine_id          = data.azurerm_virtual_machine.vm.id
  publisher                   = "Microsoft.EnterpriseCloud.Monitoring"
  type                        = "MicrosoftMonitoringAgent"
  type_handler_version        = "1.0"
  auto_upgrade_minor_version  = true

  settings = jsonencode({
    workspaceId = module.la.workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = module.la.primary_shared_key
  })
}

# LINUX VM: OmsAgentForLinux
resource "azurerm_virtual_machine_extension" "mma_linux" {
  count                       = var.vm_os_type == "Linux" ? 1 : 0
  name                        = "OmsAgentForLinux"
  virtual_machine_id          = data.azurerm_virtual_machine.vm.id
  publisher                   = "Microsoft.EnterpriseCloud.Monitoring"
  type                        = "OmsAgentForLinux"
  type_handler_version        = "1.13"
  auto_upgrade_minor_version  = true

  settings = jsonencode({
    workspaceId = module.la.workspace_id
  })

  protected_settings = jsonencode({
    workspaceKey = module.la.primary_shared_key
  })
}

# Helpful outputs
output "automation_account_name" { value = module.aa.name }
output "log_analytics_workspace" { value = module.la.name }
output "suc_id"                  { value = module.um.software_update_configuration_id }






































































