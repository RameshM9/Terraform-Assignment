variable "m_location"        
{   type = string
  description = "Location of the ResourceGroup"}
variable "m_rgname"  
{   type = string
  description = "Name of the ResourceGroup" }

variable "automation_account_id"  { type = string }
variable "automation_account_name"{ type = string }

variable "workspace_id"           { type = string }  # resource ID
variable "workspace_name"         { type = string }

# Software Update Configuration
variable "suc_name"               { type = string }
variable "os_type"                { type = string  description = "Windows or Linux" }

# Target Azure VMs (list of VM resource IDs)
variable "azure_vm_ids"           { type = list(string)  default = [] }

# Schedule
variable "start_time_utc"         { type = string  description = "ISO 8601 UTC, e.g., 2026-03-15T14:30:00Z" }
variable "time_zone"              { type = string  default = "India Standard Time" }
variable "week_days"              { type = list(string) default = ["Saturday"] } # e.g., Monday..Sunday

# Duration and reboot setting
variable "duration_iso"           { type = string  default = "PT2H" }  # ISO8601 duration
variable "reboot_setting"         { type = string  default = "IfRequired" } # Never, IfRequired, Always, RebootOnly

# Classifications
variable "windows_classifications" { type = list(string) default = ["Critical", "Security", "UpdateRollup"] }
variable "linux_classifications"   { type = list(string) default = ["Critical", "Security", "Other"] }
