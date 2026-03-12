# Introduction 
This is a Terraform Script with modules which automates the setup, creation and modification of Azure Infrastructure.
This will help you spin up azure resources in various environments.

# Getting Started
------------------
Before we begin with deployment, we should make sure have below requirements 

# 1.  Azure account with required Access
---------------------------------------

        a. Contributor access - for adding resources
        b. RBAC access - for providing permissions to existing users

# 2.  Setting up terraform CLI in your local system
-------------------------------------------------

        # Steps 

        a. Download Terraform setup from this link (https://developer.hashicorp.com/terraform/downloads)
        b. For linux, follow the given commands in the above link.
        c. Now add PATH CProgram FilesTerraform in system environment variables. (this will make terraform commands to be utilized in command prompts,IDEs and terminals)

# 3.  Download and Install Azure CLI form this link (https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

# 4.  Open any CLI (preferabily VS code - for easy command completions though below extentions)

        a. HashiCorp Terraform
        b. Azure Terraform
        c. Azure CLI Tools

# 5.  Download and Install Git Bash form this link (https://git-scm.comdownloadwin)

# Initial setup in Azure

Before we create multiple resources using terraform scripts. We should first create a storage account to save terraform state file.


# Creating or Modifying the Azure Infrastructure

1. Login to Azure from VS code (if not connected before)
  
    az login --tenant "enter organization domain"
   
2.  Set the Azure subscription in your system by running below commands
    
    az account show
    az account set --subscription="enter the subscription name"
 
3.  Once the correct subscription is set then open terraform.tfvars file form 
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

# ######################  System Patch Management 

Monitoring Patch Compliance (Portal + KQL)
1) Azure Portal (classic Update Management)

Go to Automation Account → Update management:

Machines: Onboarded VMs and compliance state
Missing updates: What’s pending and by classification
Deployment schedules / history: Success/failure per run


Or go to Log Analytics Workspace → Solutions → Update Management

2) Log Analytics (KQL) — Useful Queries

Set Time range appropriately (e.g., last 7 or 30 days).

# A. Missing updates by computer and classification
Update
| where UpdateState == "Needed"
| summarize Missing=count() by Computer, Classification
| order by Missing desc

# B. Compliance ratio per machine (installed vs needed)
let startTime = ago(30d);
Update
| where TimeGenerated >= startTime
| summarize Needed=countif(UpdateState == "Needed"),
            Installed=countif(UpdateState == "Installed")
  by Computer
| extend CompliancePct = round(100.0 * Installed / (Installed + Needed), 2)
| order by CompliancePct asc

# C. Last update deployment run status
UpdateRunProgress
| summarize arg_max(TimeGenerated, *) by CorrelationId, Computer
| project TimeGenerated, Computer, CorrelationId, Status, ErrorCode, IsCompleted
| order by TimeGenerated desc

# D. Machines not reporting (possible agent issue)
Heartbeat
| summarize LastSeen=max(TimeGenerated) by Computer
| where LastSeen < ago(1d)
| order by LastSeen asc

# E. Top missing security updates
Update
| where UpdateState == "Needed" and Classification =~ "Security"
| summarize Missing=count() by KBID, Title
| top 20 by Missing desc

# Alerts (Optional)

Create Log Alerts on the workspace using the above KQL (e.g., “Any machine with >10 missing updates” or “No heartbeat in 24h”).

# #################  Troubleshooting

# VM not visible in Update Management:
------------------------------------
Verify the MMA/OMS agent extension is installed and connected to the same workspace used by the Automation Account.
Check Heartbeat table to confirm reporting.


# No compliance data:
-----------------------
Ensure UpdateManagement solution is enabled (module created it).
Give it 15–30 minutes after onboarding.


# Schedule didn’t run:
-------------------
Confirm time zone and start_time_utc.
Check Job history under the Software Update Configuration run.


# Region mismatch:
-------------------
Automation Account and Log Analytics must be in the same region for Update Management.

1. Modular Terraform code for:
-------------------------------
1.1 automation_account
1.2 log_analytics
1.3 update_management (link + solution + schedule)


2. Root example showing:
--------------------------
2.1 Onboarding a VM to Update Management
2.2 Weekly patch deployment schedule


3. Documentation  explaining:
------------------------------
3.1 How to monitor patch compliance
3.2 KQL queries
3.3 Troubleshooting


# #######  Terraform Folder Structure ###############################

├───app-infra-setup
│   └───modules
│       ├───app_nodes_module
│       ├───infra_modules
│       │   ├───azure-nsg
│       │   ├───azure-rg
│       │   ├───azure-subnet
│       │   ├───azure-vms
│       │   └───azure-vnet
│       └───system_patch_mgmt_modules
│           ├───azure_automation_account
│           ├───azure_log_analytics
│           └───azure_update_management
└───pipelines









