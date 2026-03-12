# Introduction 
This is a Terraform Script with modules which automates the setup, creation and modification of Azure Infrastructure.
This will help you spin up azure resources in various environments.

# Getting Started
Before we begin with deployment, we should make sure have below requirements 

1.  Azure account with required Access

        a. Contributor access - for adding resources
        b. RBAC access - for providing permissions to existing users

2.  Setting up terraform CLI in your local system

        Steps 

        a. Download Terraform setup from this link (https://developer.hashicorp.com/terraform/downloads)
        b. For linux, follow the given commands in the above link.
        c. Now add PATH CProgram FilesTerraform in system environment variables. (this will make terraform commands to be utilized in command prompts,IDEs and terminals)

3.  Download and Install Azure CLI form this link (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

4.  Open any CLI (preferabily VS code - for easy command completions though below extentions)

        a. HashiCorp Terraform
        b. Azure Terraform
        c. Azure CLI Tools

5.  Download and Install Git Bash form this link (https://git-scm.comdownloadwin)

# Initial setup in Azure

Before we create multiple resources using terraform scripts. We should first create a storage account to save terraform state file.

For that,

        - open git bash terminal in VS code and navigate to the source code folder evertzpocsandboxsb1
        - alter the following variable values in shell script initial_setup.sh [resourceGroupName,storageAccountName,containerName,location,sku,subscriptionName]
        - run the script after saving the changes (login to azure account when prompts)

Run the command 
``` 
sh initial_setup.sh 
```
            
Note The above shell script will create a base resource group,storage account,container (if not exist with the same) and fetch the access key to make connection with your local system.

Also, when you initialize the terraform from your local system, it will save the state file and keep updating when ever you make changes.

# Creating or Modifying the Azure Infrastructure

1. Login to Azure from VS code (if not connected before)
    ```
    az login --tenant "enter organization domain"
    ```
2.  Set the Azure subscription in your system by running below commands
    ```
    az account show
    az account set --subscription="enter the subscription name"
    ```
3.  Once the correct subscription is set then open terraform.tfvars file form evertzpocsandboxsb1tfvars.
4.  Make the changes to the values as per your resource requirements and save the file.
5. The cloud-init script in this project performs the following steps:

Updates the package repository
Installs NGINX
Enables NGINX to start on reboot
Starts the NGINX service immediately
(Optional) Creates a simple HTML landing page

As a result, once Terraform finishes:

The VM is already running
NGINX is installed and active
The web server is accessible via the VM’s public IP on port 80 













