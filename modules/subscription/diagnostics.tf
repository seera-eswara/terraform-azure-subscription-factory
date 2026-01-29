# ============================================================================
# Diagnostic Settings for Subscription
# ============================================================================
# Configure comprehensive logging for audit, compliance, and troubleshooting
# 
# COST NOTES:
# - Log Analytics Workspace: ~$0.50-2/day (low cost, included in baseline)
# - Activity Logs to Event Hub: FREE (comment enabled by default)
# - Activity Logs to Storage: ~$0.023 per 100,000 operations (very cheap, commented)
# - Metrics: FREE with Log Analytics
#
# RECOMMENDATION: Keep Log Analytics enabled, storage is optional for long-term archival
# ============================================================================

# Configure subscription activity log diagnostics
# Routes Azure Activity Logs to Log Analytics for monitoring and troubleshooting
resource "azurerm_monitor_diagnostic_setting" "subscription_activity_logs" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "diag-activity-logs-${var.app_code}"
  target_resource_id         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.baseline.id

  enabled_log {
    category = "Administrative"
  }

  enabled_log {
    category = "Alert"
  }

  enabled_log {
    category = "Autoscale"
  }

  enabled_log {
    category = "Policy"
  }

  enabled_log {
    category = "Recommendation"
  }

  enabled_log {
    category = "ResourceHealth"
  }

  enabled_log {
    category = "Security"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# COST OPTIMIZATION: Event Hub diagnostic sink is commented out
# WHY: FREE tier limits may apply, but setup is minimal cost
# WHEN TO ENABLE: For real-time streaming to other systems (SIEM, custom analytics)
# HOW TO ENABLE: Uncomment and provide event_hub_authorization_rule_id
#
# Requires: Azure Event Hubs namespace in hub subscription
# Cost: FREE with consumption-based pricing
# 
# To use:
#   1. Set enable_diagnostic_settings = true
#   2. Create Event Hubs namespace in hub/shared services subscription
#   3. Provide event_hub_authorization_rule_id variable
#   4. Uncomment the block below
#
# resource "azurerm_monitor_diagnostic_setting" "subscription_activity_logs_eventhub" {
#   count = var.enable_diagnostic_settings && var.event_hub_authorization_rule_id != null ? 1 : 0
#
#   name                          = "diag-activity-logs-eventhub-${var.app_code}"
#   target_resource_id            = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   eventhub_authorization_rule_id = var.event_hub_authorization_rule_id
#
#   enabled_log {
#     category = "Administrative"
#   }
#
#   enabled_log {
#     category = "Security"
#   }
#
#   metric {
#     category = "AllMetrics"
#     enabled  = true
#   }
# }

# COST OPTIMIZATION: Storage account diagnostic sink is commented out
# WHY: Minimal cost (~$0.023 per 100K operations), but adds complexity
# WHEN TO ENABLE: Long-term log archival (compliance/audit requirements)
# COST: Very cheap (~$5-10/month for typical workload)
#
# To use:
#   1. Create or reference existing storage account in hub subscription
#   2. Provide storage_account_id variable
#   3. Uncomment the block below
#
# resource "azurerm_monitor_diagnostic_setting" "subscription_activity_logs_storage" {
#   count = var.enable_diagnostic_settings && var.storage_account_id != null ? 1 : 0
#
#   name                   = "diag-activity-logs-storage-${var.app_code}"
#   target_resource_id     = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
#   storage_account_id     = var.storage_account_id
#
#   enabled_log {
#     category = "Administrative"
#   }
#
#   enabled_log {
#     category = "Security"
#   }
#
#   retention_policy {
#     enabled = true
#     days    = 90  # Rotate logs after 90 days
#   }
# }

# Get current subscription context for diagnostic settings
data "azurerm_client_config" "current" {}
