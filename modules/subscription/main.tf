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

  name     = var.resource_group_name
  location = var.location

  tags = merge(
    var.tags,
    {
      Purpose = "Baseline Infrastructure"
    }
  )
}

resource "azurerm_log_analytics_workspace" "baseline" {
  provider = azurerm.subscription

  name                = var.law_name
  location            = var.location
  resource_group_name = azurerm_resource_group.baseline.name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = merge(
    var.tags,
    {
      Purpose = "Baseline Monitoring"
    }
  )
}

# DDoS Protection Plan (optional but recommended for enterprise)
resource "azurerm_network_ddos_protection_plan" "baseline" {
  count = var.enable_ddos_protection ? 1 : 0

  provider = azurerm.subscription

  name                = "${var.resource_group_name}-ddos"
  location            = var.location
  resource_group_name = azurerm_resource_group.baseline.name

  tags = var.tags
}
