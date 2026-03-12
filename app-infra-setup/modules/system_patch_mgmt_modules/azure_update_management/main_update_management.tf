# Link Automation Account to Log Analytics Workspace
resource "azurerm_automation_linked_workspace" "link" {
  automation_account_id = var.automation_account_id
  workspace_id          = var.workspace_id
}

# Enable the Update Management solution on the workspace
resource "azurerm_log_analytics_solution" "update_mgmt" {
  solution_name         = "UpdateManagement"
  location              = var.m_location
  resource_group_name   = var.m_rgname
  workspace_resource_id = var.workspace_id
  workspace_name        = var.workspace_name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/UpdateManagement"
  }

  depends_on = [azurerm_automation_linked_workspace.link]
}

# Software Update Configuration (weekly schedule)
resource "azurerm_automation_software_update_configuration" "suc" {
  name                    = var.suc_name
  resource_group_name     = var.m_rgname
  automation_account_name = var.automation_account_name

  schedule {
    description = "Weekly patch schedule via Terraform"
    frequency   = "Week"
    interval    = 1
    start_time  = var.start_time_utc
    time_zone   = var.time_zone
    week_days   = var.week_days
  }

  update_configuration {
    operating_system = var.os_type # "Windows" or "Linux"
    duration         = var.duration_iso
    reboot_setting   = var.reboot_setting

    dynamic "windows" {
      for_each = var.os_type == "Windows" ? [1] : []
      content {
        classifications_included = var.windows_classifications
        # optional: excluded_kb_numbers         = []
        # optional: included_kb_numbers         = []
      }
    }

    dynamic "linux" {
      for_each = var.os_type == "Linux" ? [1] : []
      content {
        classifications_included     = var.linux_classifications
        # optional: package_name_masks_to_exclude = []
        # optional: package_name_masks_to_include = []
      }
    }

    targets {
      azure_virtual_machines = var.azure_vm_ids
      # Alternatively use 'azure_queries' to target by subscription/rg/tags.
    }
  }

  depends_on = [azurerm_log_analytics_solution.update_mgmt]
}