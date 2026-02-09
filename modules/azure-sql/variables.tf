variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "sql_server_name" {
  description = "Globally unique Azure SQL Server name."
  type        = string
}

# Azure AD administrator
variable "sql_ad_admin_login" {
  description = "Azure AD admin login display name."
  type        = string
}

variable "sql_ad_admin_object_id" {
  description = "Azure AD admin object ID."
  type        = string
}

variable "sql_ad_auth_only" {
  description = "Enforce Azure AD-only authentication (no SQL password auth)."
  type        = bool
  default     = true
}

# Database
variable "database_name" {
  description = "Name of the SQL database."
  type        = string
}

variable "database_sku" {
  description = "Database SKU name (e.g. S0, GP_S_Gen5_2, GP_Gen5_2)."
  type        = string
  default     = "S0"
}

variable "database_max_size_gb" {
  description = "Maximum database size in GB."
  type        = number
  default     = 50
}

variable "database_collation" {
  description = "Database collation."
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "database_zone_redundant" {
  description = "Enable zone redundancy for the database."
  type        = bool
  default     = false
}

# Retention
variable "short_term_retention_days" {
  description = "Point-in-time restore retention in days (1-35)."
  type        = number
  default     = 7
}

variable "ltr_weekly_retention" {
  description = "Long-term weekly retention (ISO 8601 duration, e.g. P4W)."
  type        = string
  default     = "P4W"
}

variable "ltr_monthly_retention" {
  description = "Long-term monthly retention (ISO 8601 duration, e.g. P12M)."
  type        = string
  default     = "P12M"
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
