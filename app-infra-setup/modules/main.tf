
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
  name                 = var.evertz_dev_vnet_name
  resource_group_name  = var.evertz_dev_vnet-rg_name
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
module "nodes" {
  for_each = var.node_details
  source = "./modules/app_nodes_module"
  m_create_node_public_ip = each.value.create_node_public_ip
  m_subnet_id = module.snet[each.value.subnet_index].subnet_id
  m_node_count = each.value.node_count
  m_nodename = "${var.app_prefix}-${var.rg_names[each.value.rg_index].location_prefix}-${var.env_prefix}-${each.key}"
  m_uamiid = data.azurerm_user_assigned_identity.uami.id
  m_data_disk_details = each.value.manage_data_disk
  m_location = module.rg[each.value.rg_index].rg_location
  m_rgname = module.rg[each.value.rg_index].rg_name
  m_nodesize = each.value.size
  m_username = each.value.username
  m_password = each.value.password
  m_os_disk_storage_account_type = each.value.os_disk_type
  m_disk_size_gb = each.value.os_disk_size_gb
  m_auto_shutdown_details = each.value.manage_auto_shutdown
  m_tags = var.tags


  m_associate_azure_monitor = lower(var.associate_dcr_to_all_nodes) == "yes" ? "yes" : "no"
 # m_dcrid = data.azurerm_monitor_data_collection_rule.dcr.id

depends_on = [ module.snet]
}


resource "null_resource" "configure_cluster" {
  depends_on = [ module.vnet-peering , module.nodes ]
  count = sum(values(var.node_details).*.node_count) > 0 ? 1 : 0
  triggers = {
    all_instance_private_ips = join(",", concat(module.nodes["WEBSERVER"].node_priv_ip)) 
  }
 
}


  provisioner "remote-exec" {
    inline = [
      "set -x",
      "sudo sed -i 's/Operator/WEBSERVER-${count.index}/g' /etc/vue/models",
      "/opt/webapp/bin/python /tmp/configure_system_io.py -v ${var.video_standard} -i 0 -o 0 -m 0",
      "sudo start dcscloudbootstrap",
      "sudo dcs restart"
    ]
    connection {
      host =  lower(var.node_details["WEBSERVER"].create_node_public_ip) == "yes" ? element(concat(module.nodes["WEBSERVER"].node_pub_ip), count.index) : element(concat(module.nodes["WEBSERVER"].node_priv_ip), count.index)
      user = var.node_details["WEBSERVER"].username
      password = var.node_details["WEBSERVER"].password
    }
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








































































