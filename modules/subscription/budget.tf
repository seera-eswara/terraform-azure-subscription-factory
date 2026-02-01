resource "azurerm_consumption_budget_subscription" "monthly" {
  count = var.monthly_budget > 0 ? 1 : 0

  name = "monthly-budget"
  # Using local.subscription_id which intelligently handles both scenarios:
  # Scenario 1: Automatic subscription creation (EA/MCA accounts)
  #   - When use_existing_subscription = false
  #   - Creates new subscription via azurerm_subscription.this[0]
  #   - Requires: billing_scope_id + proper RBAC permissions
  # Scenario 2: Existing subscription management (Pay-As-You-Go accounts)
  #   - When use_existing_subscription = true
  #   - Uses existing_subscription_id provided in variables
  #   - No subscription creation permissions required
  # See main.tf for the full logic determining which path is taken
  #subscription_id = azurerm_subscription.this.subscription_id
  subscription_id = local.subscription_id

  amount     = var.monthly_budget
  time_grain = "Monthly"

  time_period {
    start_date = "2024-01-01T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = var.budget_alert_threshold
    operator       = "GreaterThan"
    contact_emails = var.alert_emails
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    contact_emails = var.alert_emails
  }
}
