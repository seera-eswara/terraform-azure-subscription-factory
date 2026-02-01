# ============================================================================
# SUBSCRIPTION CREATION - EDUCATIONAL NOTES
# ============================================================================
# Azure supports programmatic subscription creation ONLY for these billing types:
# 
# 1. Enterprise Agreement (EA):
#    - Requires EA Enrollment Account enrollment/xxx
#    - Service Principal needs "Enrollment Account Subscription Creator" role
#    - billing_scope_id format: /providers/Microsoft.Billing/billingAccounts/{accountId}/enrollmentAccounts/{enrollmentId}
#
# 2. Microsoft Customer Agreement (MCA):
#    - Requires invoice sections under billing profiles
#    - Service Principal needs "Invoice Section Contributor" or "Billing Profile Contributor" role
#    - billing_scope_id format: /providers/Microsoft.Billing/billingAccounts/{accountId}/billingProfiles/{profileId}/invoiceSections/{sectionId}
#    - Assignment done via: Azure Portal -> Cost Management + Billing -> Invoice sections -> Access Control (IAM)
#
# 3. Microsoft Partner Agreement (MPA):
#    - For CSP partners managing customer subscriptions
#    - Requires partner-level billing access
#
# ❌ NOT SUPPORTED: Pay-As-You-Go, Free Trial, MSDN/Visual Studio subscriptions
#    - These account types CANNOT create subscriptions programmatically
#    - Must manually create subscriptions in Azure Portal
#    - Use subscription_id_override to manage existing subscriptions
#
# To enable automatic subscription creation:
# 1. Verify billing account type: az billing account show --name "{accountId}"
# 2. For MCA: Assign SP role at invoice section (see RBAC steps above)
# 3. For EA: Get enrollment account and assign SP as subscription creator
# 4. Set use_existing_subscription = false and provide billing_scope_id
# ============================================================================

# Create new subscription only for EA/MCA accounts with proper billing permissions
# For Pay-As-You-Go: Set use_existing_subscription = true and skip this resource
resource "azurerm_subscription" "this" {
  count = var.use_existing_subscription ? 0 : 1

  subscription_name = var.subscription_name
  billing_scope_id  = var.billing_scope_id
  
  # This resource requires:
  # - Valid billing_scope_id (EA enrollment or MCA invoice section)
  # - Service Principal with subscription creation permissions at billing scope
  # - Will fail with "InsufficientPermissionsOnInvoiceSection" error if permissions missing
}

# Use existing subscription if provided (for Pay-As-You-Go or manual subscription management)
locals {
  # Intelligent subscription ID selection:
  # - If use_existing_subscription=true: use the provided existing subscription ID
  # - If use_existing_subscription=false: use the newly created subscription (requires valid billing_scope_id and permissions)
  # This design allows the same factory to work with both automatic creation (EA/MCA) and existing subscriptions (Pay-As-You-Go)
  subscription_id = var.use_existing_subscription ? var.existing_subscription_id : azurerm_subscription.this[0].subscription_id
  
  # Full subscription ID path required by management group association
  subscription_id_path = "/subscriptions/${local.subscription_id}"
}

resource "azurerm_management_group_subscription_association" "mg" {
  management_group_id = var.management_group_id
  subscription_id     = local.subscription_id_path
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

