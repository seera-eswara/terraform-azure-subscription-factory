terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0, < 5.0"
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
}

provider "azuread" {
  use_oidc = true
}

# Provider for the newly created subscription
provider "azurerm" {
  alias           = "subscription"
  subscription_id = module.subscription.subscription_id
  features {}
  use_oidc = true
}
