terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
  # Dynamically uses the active subscription from Azure CLI context
  # This is typically where the Terraform state backend is stored (cloud-infra-sub)
  # No need to hardcode - just set the right subscription with: az account set --subscription <id>
  # Falls back to backend_subscription_id variable if you need to override
  subscription_id = var.backend_subscription_id != null ? var.backend_subscription_id : data.azurerm_client_config.current.subscription_id
}

provider "azuread" {
  use_oidc = true
}

# Provider for the newly created subscription
provider "azurerm" {
  alias           = "subscription"
  subscription_id = coalesce(var.subscription_id_override, data.azurerm_client_config.current.subscription_id)
  features {}
  use_oidc = true
}
