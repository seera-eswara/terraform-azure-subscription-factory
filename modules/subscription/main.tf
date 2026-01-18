resource "azurerm_subscription" "this" {
  subscription_name = var.subscription_name
  billing_scope_id  = var.billing_scope_id
}

resource "azurerm_management_group_subscription_association" "mg" {
  management_group_id = var.management_group_id
  subscription_id     = azurerm_subscription.this.subscription_id
}

resource "azurerm_role_assignment" "owners" {
  for_each = toset(var.owners)

  scope                = azurerm_subscription.this.subscription_id
  role_definition_name = "Owner"
  principal_id         = each.value
}

# Baseline infrastructure for the subscription
resource "azurerm_resource_group" "baseline" {
  provider = azurerm.subscription

  name     = "rg-${var.subscription_name}-baseline"
  location = var.location

  tags = {
    Environment = var.environment
    ManagedBy   = "subscription-factory"
  }
}

resource "azurerm_log_analytics_workspace" "baseline" {
  provider = azurerm.subscription

  name                = "law-${var.subscription_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.baseline.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = {
    Environment = var.environment
    ManagedBy   = "subscription-factory"
  }
}
