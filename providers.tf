provider "azurerm" {
  features {}
}

# Provider for the newly created subscription
provider "azurerm" {
  alias           = "subscription"
  subscription_id = module.subscription.subscription_id
  features {}
}
