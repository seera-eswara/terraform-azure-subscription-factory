variable "subscription_name" {
  description = "Name of the subscription to create"
  type        = string
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
  description = "Environment name (dev, staging, prod)"
  type        = string
}
