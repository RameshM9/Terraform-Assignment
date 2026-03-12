# Module Main
# Below declared variables are common for all the resources

app_prefix  = "base"
env_prefix =  "demo"
tags = {Application = "base", Environment = "demo", Purpose = "infrastructure provisioning", CreatedWith = "Terraform Pipeline"}

# Module Resource Group
# Below declared variable creates the resource group with the given key as names and values as location.
                            #RGNmae   
rg_names = [{rg_name_sufix = "rg" , location = "East US" , location_prefix = "eu"}]

# Module Virtual Network
# Below declared variables creates Virtual Network with the given values
                               
virtualnetworks = [
           #VnetName          #VnetCIDR                #VnetRG
    {vnetname = "vnet" , address = "10.99.0.0/16" , rg_index = 0}
]

# Module Subnets
# Below declared variables creates subnets with the given values

subnets = [
           #SnetName          #SnetCIDR              #Snet'sVnet      #Snet'sNSG
    {snetname = "snet" , address = "10.99.0.0/24" , vnet_index = 0 , nsg_index = 0}
]

# Module Network Security Group
# Below declared variables creates Network Security Group and Security rules with the given values

nsg_with_rules = {

    "nsg" = {
        rg_index  = 0
        rules = [ {
            name                                       = "Allowed_In"
            priority                                   = 300
            direction                                  = "Inbound"
            access                                     = "Allow"
            protocol                                   = "*"
            source_port_range                          = "*"
            destination_port_range                     = ""
            source_port_ranges                         = []
            destination_port_ranges                    = ["22","80"]
            source_address_prefix                      = "*"
            destination_address_prefix                 = "*"
            source_address_prefixes                    = []
            destination_address_prefixes               = []
            source_application_security_group_ids      = []
            destination_application_security_group_ids = []
            }
        ]
    }
}

# Module Virtual_Networks_Peering
## Below variable will create the resource if the value is any one of this list [yes,yeS,yES,YES,Yes,YEs,YeS]. 
#Else it will skip the module for any other values [no,No,NO,nO]  

# trdemorm_dev_vnet_name = "live-media-deploy-vnet"
# trdemorm_dev_vnet-rg_name = "live-media-deploy"

create_vnetpeering = "yes"


# Module Nodes

#Below variables fetches the details of existing resources
existing_uami = {
  name = "tfdemo-managed-identity" 
  rg = "tfdemo-devops"
}
existing_dcr = {
  name = "MSVMI-trdemormloganalytics-eu"
  rg = "tfdemo-devops"
}

# Below declared variables creates Application Nodes in the provided subnet with the given values

associate_dcr_to_all_nodes = "yes"

node_details = {
    WEBSERVER ={ 
        node_count               = 1      
        rg_index                 = 0
        subnet_index             = 0
        create_node_public_ip    = "yes"    
        size                     = "Standard_F8s_v2"
        username                 = "trdemorm"
        password                 = "tfdemotest@123"
        os_disk_type             = "Standard_LRS"
        os_disk_size_gb          = 64
       #manage_data_disk         = {create_managed_disk  = "yes" , datadisk_type  = "Standard_LRS" , datadisk_size_gb = "128"}

    } 
}

############## Operational Parameters ##############
# Default video standard configuration.

video_standard = "1080p5994"

# Module Role Assignment for users
# Below declared variables provides Role Definition to the users for resource group
# This variable will allow assigning role definitions to users i.e., keys(userroles).

run_urole_module = "No" 

userroles = { 
     
    "userone@tfdemo.net" = {rg_index = 0 , role_defs = ["Reader"]},
    "usertwo@tfdemo.net"  = {rg_index = 0 , role_defs = ["Owner", "Reader"]},
    "userthree@tfdemo.net"   = {rg_index = 0 , role_defs = ["Owner","Reader"]}
}

# Module Virtual_Machine
# Use this module only if you want to create general user vms
# Below declared variables creates virtual machines in the provided subnet with the given values
## Below "create_virtual_machines" variable will run the vms module if the value is any one of this list [yes,yeS,yES,YES,Yes,YEs,YeS]. 
#Else it will skip the vms module for any other values [no,No,NO,nO]

create_virtual_machines = "no"

vm_details = {
    "avm" ={ 
        vm_count             = 0   
        rg_index             = 0
        subnet_index         = 0
        create_vm_public_ip  = "yes"    # This variable will allow assigning public ip to vm
        size                 = "Standard_B1ls"
        username             = "trdemorm"
        password             = "tfdemotest@123"
        disk_type            = "Standard_LRS"
        disk_size_gb         = 64
        os_image             = {
            publisher = "Canonical"
            offer     = "UbuntuServer"
            sku       = "18.04-LTS" 
            version   = "latest"
        }
    }
}

############## System Patch Management #####################

spm_prefix              = "spm-prefix"
#rg_names  = "rg-prod-hyd"
vm_resource_group   = "rg-prod-hyd"
vm_name             = "vm-app-01"
vm_os_type          = "Windows"
# Friday 20:30 UTC = Saturday 02:00 IST
suc_start_time_utc  = "2026-03-13T20:30:00Z"
