output "subscription_id" {
  description = "The ID of the created subscription"
  value       = azurerm_subscription.this.subscription_id
}

output "subscription_name" {
  description = "The name of the created subscription"
  value       = azurerm_subscription.this.subscription_name
}

output "resource_group_name" {
  description = "The baseline resource group name"
  value       = azurerm_resource_group.baseline.name
}

output "resource_group_id" {
  description = "The baseline resource group ID"
  value       = azurerm_resource_group.baseline.id
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.baseline.id
}

output "log_analytics_workspace_name" {
  description = "The Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.baseline.name
}

output "ddos_protection_plan_id" {
  description = "The DDoS Protection Plan ID"
  value       = try(azurerm_network_ddos_protection_plan.baseline[0].id, null)
}
