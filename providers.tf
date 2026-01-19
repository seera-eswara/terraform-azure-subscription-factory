terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.57"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Provider for the newly created subscription
provider "azurerm" {
  alias           = "subscription"
  subscription_id = module.subscription.subscription_id
  features {}
}
