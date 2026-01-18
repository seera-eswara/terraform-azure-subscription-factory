resource "azurerm_consumption_budget_subscription" "monthly" {
  name            = "monthly-budget"
  subscription_id = var.subscription_id

  amount     = var.monthly_budget
  time_grain = "Monthly"

  notification {
    enabled   = true
    threshold = 80
    operator  = "GreaterThan"
    contact_emails = var.alert_emails
  }
}
