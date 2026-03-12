variable "m_log_analyticsname"   {         
  type = string
  description = "Name of the Log Analytics"
}
variable "m_location"        
{   type = string
  description = "Location of the ResourceGroup"}
variable "m_rgname"  
{   type = string
  description = "Name of the ResourceGroup" }
variable "m_sku"             
{ type = string  default = "PerGB2018" }
variable "m_retention_days"  
{ type = number  
default = 30 }