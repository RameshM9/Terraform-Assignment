variable "m_automationaccountname"           
{   type = string
  description = "Name of the Automation Account" 
  }

variable "m_sku_name"      
 { type = string  
 default = "Basic" } # Basic is supported for Update Mgmt

variable "m_location"        
{   type = string
  description = "Location of the ResourceGroup"}
variable "m_rgname"  
{   type = string
  description = "Name of the ResourceGroup" }
variable "m_sku_name"             
{ type = string  default = "PerGB2018" }