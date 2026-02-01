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
  # Use ARM_SUBSCRIPTION_ID (GitHub Actions) or current Azure CLI context (local)
  # Avoids provider/data cycles by not referencing azurerm_client_config here
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
