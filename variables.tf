variable "subscription_name" {
  description = "Name of the subscription to create"
  type        = string
}

variable "app_code" {
  description = "Three-letter application code used for naming and management group mapping"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3}$", var.app_code))
    error_message = "app_code must be exactly 3 lowercase alphanumeric characters (e.g., app, crm, erp)."
  }
}

variable "management_group_prefix" {
  description = "Prefix for team management groups under LandingZones (e.g., lz-app, lz-crm)"
  type        = string
  default     = "lz"
}

variable "billing_scope_id" {
  description = "Azure billing scope ID for subscription creation"
  type        = string
}

variable "owners" {
  description = "List of principal IDs to assign as subscription owners"
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region for baseline resources"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "Environment name (dev, stage, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "stage", "prod", "qa", "uat"], var.environment)
    error_message = "Environment must be one of: dev, stage, prod, qa, uat."
  }
}

variable "billing_entity" {
  description = "Cost center or billing entity for chargeback"
  type        = string
  default     = "platform"
}

# Budget & Cost Management
variable "monthly_budget" {
  description = "Monthly budget limit in USD (0 = disabled)"
  type        = number
  default     = 0

  validation {
    condition     = var.monthly_budget >= 0
    error_message = "Monthly budget must be >= 0."
  }
}

variable "budget_alert_threshold" {
  description = "Alert when budget exceeds this percentage (0-100)"
  type        = number
  default     = 80

  validation {
    condition     = var.budget_alert_threshold >= 0 && var.budget_alert_threshold <= 100
    error_message = "Budget alert threshold must be between 0 and 100."
  }
}

variable "alert_emails" {
  description = "Email addresses to notify for budget alerts"
  type        = list(string)
  default     = []
}

# Security & Compliance
variable "enable_defender" {
  description = "Enable Microsoft Defender for Cloud"
  type        = bool
  default     = true
}

variable "enable_ddos_protection" {
  description = "Enable DDoS protection for virtual networks"
  type        = bool
  default     = true
}

