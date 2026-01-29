variable "subscription_name" {
  type = string
}

variable "billing_scope_id" {
  type = string
}

variable "management_group_id" {
  type = string
}

variable "owners" {
  type = list(string)
}

variable "location" {
  description = "Azure region for baseline resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "resource_group_name" {
  description = "Name for baseline resource group (from naming module)"
  type        = string
}

variable "law_name" {
  description = "Name for log analytics workspace (from naming module)"
  type        = string
}

variable "monthly_budget" {
  description = "Monthly budget limit in USD (0 = disabled)"
  type        = number
  default     = 0
}

variable "budget_alert_threshold" {
  description = "Alert when budget exceeds this percentage"
  type        = number
  default     = 80
}

variable "alert_emails" {
  description = "Email addresses for budget alerts"
  type        = list(string)
  default     = []
}

variable "enable_defender" {
  description = "Enable Microsoft Defender for Cloud"
  type        = bool
  default     = true
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "app_code" {
  description = "Application code/name (e.g., app1, payment-service)"
  type        = string
}

variable "create_policy_assignments" {
  description = "Whether to create app-specific policy assignments"
  type        = bool
  default     = true
}

variable "allowed_regions" {
  description = "Allowed Azure regions for resource deployment"
  type        = list(string)
  default     = ["eastus", "westus2"]
}

variable "required_tags" {
  description = "Required tags for all resources"
  type        = list(string)
  default     = ["Environment", "CostCenter", "Owner"]
}

# RBAC group display names
variable "app_contributor_groups" {
  description = "Azure AD group display names to grant Contributor at subscription scope"
  type        = list(string)
  default     = []
}

variable "finops_reader_groups" {
  description = "Azure AD group display names to grant Reader at subscription scope"
  type        = list(string)
  default     = []
}

# Networking Variables
variable "create_spoke_vnet" {
  description = "Whether to create a spoke VNet for this app"
  type        = bool
  default     = false
}

variable "spoke_vnet_name" {
  description = "Name of the spoke virtual network"
  type        = string
  default     = ""
}

variable "spoke_vnet_address_space" {
  description = "Address space(s) for the spoke VNet"
  type        = list(string)
  default     = ["10.100.0.0/16"]
}

variable "app_subnet_prefix" {
  description = "Address prefix for application subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "enable_aks_subnet" {
  description = "Whether to create AKS subnet"
  type        = bool
  default     = false
}

variable "aks_subnet_prefix" {
  description = "Address prefix for AKS subnet"
  type        = string
  default     = "10.100.2.0/24"
}

variable "enable_database_subnet" {
  description = "Whether to create database subnet"
  type        = bool
  default     = false
}

variable "database_subnet_prefix" {
  description = "Address prefix for database subnet"
  type        = string
  default     = "10.100.3.0/24"
}

variable "enable_functions_subnet" {
  description = "Whether to create Azure Functions subnet"
  type        = bool
  default     = false
}

variable "functions_subnet_prefix" {
  description = "Address prefix for Azure Functions subnet"
  type        = string
  default     = "10.100.4.0/24"
}

variable "enable_private_endpoints_subnet" {
  description = "Whether to create private endpoints subnet"
  type        = bool
  default     = false
}

variable "private_endpoints_subnet_prefix" {
  description = "Address prefix for private endpoints subnet"
  type        = string
  default     = "10.100.5.0/24"
}

variable "hub_vnet_id" {
  description = "Resource ID of the hub VNet for peering"
  type        = string
  default     = null
}

variable "hub_vnet_name" {
  description = "Name of the hub VNet for peering"
  type        = string
  default     = null
}

variable "hub_vnet_address_space" {
  description = "Address space of the hub VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "use_remote_gateway" {
  description = "Whether to use remote gateway for hub VNet peering"
  type        = bool
  default     = false
}

variable "keyvault_id" {
  description = "Resource ID of Key Vault for private endpoint"
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "Resource ID of Storage Account for private endpoint"
  type        = string
  default     = null
}

variable "sqldb_id" {
  description = "Resource ID of SQL Database for private endpoint"
  type        = string
  default     = null
}

