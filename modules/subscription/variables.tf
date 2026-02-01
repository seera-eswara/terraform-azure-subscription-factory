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

# COST OPTIMIZATION NOTE: Defender for Cloud costs ~$7+/resource/month
# For learning/interview prep with limited $200 credits, disabled by default
# Production deployments should enable this for security compliance
variable "enable_defender" {
  description = "Enable Microsoft Defender for Cloud"
  type        = bool
  default     = false  # Changed from true to false for cost savings
}

# COST OPTIMIZATION NOTE: DDoS Protection costs ~$3,000/month
# Extremely expensive and unnecessary for learning environments
# Enable only in production with actual public-facing services requiring DDoS mitigation
variable "enable_ddos_protection" {
  description = "Enable DDoS protection"
  type        = bool
  default     = false  # Changed from true to false - CRITICAL cost saving measure
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

variable "billing_entity" {
  description = "Billing entity or cost center for resource tagging"
  type        = string
  default     = "shared"
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

# ============================================================================
# Diagnostics Configuration
# ============================================================================
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for subscription activity logs"
  type        = bool
  default     = true
  # COST: Free - Log Analytics workspace already included in baseline
}

variable "event_hub_authorization_rule_id" {
  description = "Event Hub authorization rule ID for streaming logs (optional)"
  type        = string
  default     = null
  # COST: Free - only pay if using Event Hub for other purposes
}

# ============================================================================
# Identity Configuration
# ============================================================================
variable "enable_app_identity" {
  description = "Create user-assigned managed identity for the application"
  type        = bool
  default     = true
  # COST: Free - no additional charges for managed identities
}

# ============================================================================
# Monitoring and Alerting Configuration
# ============================================================================
variable "enable_monitoring" {
  description = "Enable monitoring, alerting, and action groups"
  type        = bool
  default     = true
  # COST: Free - action groups and basic alert rules are free
}

variable "alert_email_addresses" {
  description = "Email addresses for alert notifications"
  type        = list(string)
  default     = []
  # COST: Free - email notifications don't incur charges
}

variable "webhook_url" {
  description = "Webhook URL for custom alert integrations (Slack, Teams, etc)"
  type        = string
  default     = null
  # COST: Free webhook receiver, external service cost depends on integration
}

