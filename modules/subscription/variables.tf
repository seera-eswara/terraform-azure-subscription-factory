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
