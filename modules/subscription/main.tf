# Create new subscription only if not using existing one
resource "azurerm_subscription" "this" {
  count = var.use_existing_subscription ? 0 : 1

  subscription_name = var.subscription_name
  billing_scope_id  = var.billing_scope_id
}

# Use existing subscription if provided
locals {
  subscription_id = var.use_existing_subscription ? var.existing_subscription_id : azurerm_subscription.this[0].subscription_id
}

resource "azurerm_management_group_subscription_association" "mg" {
  management_group_id = var.management_group_id
  subscription_id     = local.subscription_id
}

resource "azurerm_role_assignment" "owners" {
  for_each = toset(var.owners)

  scope                = "/subscriptions/${local.subscription_id}"
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
      InfraComponent = "diagnostics"  # Infrastructure component tag for cost tracking
    }
  )
}

# ============================================================================
# COST OPTIMIZATION: DDoS Protection Disabled
# ============================================================================
# DDoS Protection Plan is DISABLED by default to preserve Azure free credits
#
# COST: ~$3,000/month (EXTREMELY EXPENSIVE)
#
# WHEN TO ENABLE (Production Only):
# 1. Set variable.enable_ddos_protection = true in terraform.tfvars
# 2. Only if you have public-facing applications requiring DDoS mitigation
# 3. Ensure enterprise budget approval (~$36,000/year)
# 4. Monitor costs weekly in Azure Cost Management
#
# LEARNING REFERENCE:
# This code demonstrates Azure DDoS Protection architecture.
# Understand the cost implications before enabling in any environment.
# ============================================================================

# DDoS Protection Plan (COMMENTED OUT - extremely costly)
# Uncomment ONLY when enable_ddos_protection = true AND you have budget
# resource "azurerm_network_ddos_protection_plan" "baseline" {
#   count = var.enable_ddos_protection ? 1 : 0
#
#   provider = azurerm.subscription
#
#   name                = "${var.resource_group_name}-ddos"
#   location            = var.location
#   resource_group_name = azurerm_resource_group.baseline.name
#
#   tags = var.tags
# }

