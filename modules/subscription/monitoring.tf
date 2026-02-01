# ============================================================================
# Monitoring, Alerting, and Action Groups
# ============================================================================
# Set up comprehensive monitoring for operational insights and incident response
#
# COST NOTES:
# - Action Groups: FREE
# - Alert Rules: FREE for first 1,000 rules per subscription
# - Email notifications: FREE
# - SMS/Webhooks: Minimal cost (~$0.50 per SMS)
# - Metric alerts: FREE (first 10 metric alert rules)
#
# RECOMMENDATION: Keep enabled - very cost-effective for operational visibility
# ============================================================================

# Action Group for notifications
# Central hub for all alert notifications (email, webhook, automation)
resource "azurerm_monitor_action_group" "app_alerts" {
  count = var.enable_monitoring ? 1 : 0

  resource_group_name = azurerm_resource_group.baseline.name
  name                = "ag-${var.app_code}-${var.environment}"
  short_name          = var.app_code

  tags = merge(
    var.tags,
    {
      Purpose = "Application Alerts"
      InfraComponent = "monitoring"  # Infrastructure component tag for cost tracking
    }
  )
}

# Email receivers are configured inline within the action group resource
# The azurerm_monitor_action_group_email_receiver resource type is not supported
# Use email_receiver blocks within azurerm_monitor_action_group instead

# COST OPTIMIZATION: Webhook receiver is disabled by default
# WHY: Typically used for custom integrations (Slack, Teams, etc)
# COST: FREE - only pay for external service if applicable
#
# To enable: Uncomment and provide webhook URLs
# Example use cases:
#   - Slack notifications
#   - Custom incident management
#   - External monitoring system integration
#
# resource "azurerm_monitor_action_group_webhook_receiver" "app_webhook" {
#   count = var.enable_monitoring && var.webhook_url != null ? 1 : 0
#
#   action_group_name   = azurerm_monitor_action_group.app_alerts[0].name
#   name                = "webhook-notifications"
#   service_uri         = var.webhook_url
#   use_common_alert_schema = true
# }

# Log Analytics Alert Rule: High CPU Usage
# Monitors for sustained high CPU on resources in the subscription
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "high_cpu" {
  count = var.enable_monitoring ? 1 : 0

  name                = "alert-high-cpu-${var.app_code}"
  resource_group_name = azurerm_resource_group.baseline.name
  location            = var.location

  evaluation_frequency = "PT5M"  # Every 5 minutes
  window_duration      = "PT15M" # 15-minute window
  severity             = 2        # Warning level

  criteria {
    operator       = "GreaterThan"
    threshold      = 80.0
    time_aggregation_method = "Average"

    failing_periods {
      min_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods          = 1
    }

    dimension {
      name     = "Computer"
      operator = "Include"
      values   = ["*"]
    }
  }

  scopes = [azurerm_log_analytics_workspace.baseline.id]

  data_source_id = azurerm_log_analytics_workspace.baseline.id

  query = <<-QUERY
    Perf
    | where ObjectName == "Processor" and CounterName == "% Processor Time"
    | where InstanceName == "_Total"
    | summarize AvgCPU = avg(CounterValue) by Computer
    | where AvgCPU > 80
  QUERY

  action_scope {
    action_group_ids = [azurerm_monitor_action_group.app_alerts[0].id]
  }

  display_description = "Triggers alert when average CPU exceeds 80% for ${var.app_code}"
  auto_remediate       = false

  depends_on = [azurerm_monitor_action_group.app_alerts]
}

# COST OPTIMIZATION: Storage account full alert is commented
# WHY: Useful for long-term archival, but basic subscriptions may not need
# COST: FREE alert rule
#
# Uncomment to monitor for storage capacity issues
#
# resource "azurerm_monitor_metric_alert" "storage_capacity" {
#   count = var.enable_monitoring && var.storage_account_id != null ? 1 : 0
#
#   name                = "alert-storage-capacity-${var.app_code}"
#   resource_group_name = azurerm_resource_group.baseline.name
#   scopes              = [var.storage_account_id]
#   description         = "Alert when storage capacity exceeds 80%"
#   severity            = 2
#
#   criteria {
#     metric_name       = "UsedCapacity"
#     metric_namespace  = "microsoft.storage/storageaccounts"
#     aggregation       = "Average"
#     operator          = "GreaterThan"
#     threshold         = 85899345920  # 80GB in bytes
#   }
#
#   action {
#     action_group_id = azurerm_monitor_action_group.app_alerts[0].id
#   }
# }

# Output action group for custom alert creation
output "action_group_id" {
  value       = try(azurerm_monitor_action_group.app_alerts[0].id, null)
  description = "Action group ID for alert notifications (use for custom alerts)"
}

output "action_group_name" {
  value       = try(azurerm_monitor_action_group.app_alerts[0].name, null)
  description = "Action group name for alert configuration"
}
