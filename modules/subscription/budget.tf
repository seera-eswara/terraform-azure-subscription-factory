resource "azurerm_consumption_budget_subscription" "monthly" {
  count = var.monthly_budget > 0 ? 1 : 0

  name            = "monthly-budget"
  subscription_id = azurerm_subscription.this.subscription_id

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
