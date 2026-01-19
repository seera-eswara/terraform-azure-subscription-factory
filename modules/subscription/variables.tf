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

