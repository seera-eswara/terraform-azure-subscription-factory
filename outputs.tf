output "subscription_id" {
  description = "The ID of the created subscription"
  value       = module.subscription.subscription_id
}

output "subscription_name" {
  description = "The name of the created subscription"
  value       = module.subscription.subscription_name
}

output "resource_group_name" {
  description = "The baseline resource group name"
  value       = module.subscription.resource_group_name
}

output "resource_group_id" {
  description = "The baseline resource group ID"
  value       = module.subscription.resource_group_id
}

output "log_analytics_workspace_id" {
  description = "The Log Analytics workspace ID"
  value       = module.subscription.log_analytics_workspace_id
}

output "log_analytics_workspace_name" {
  description = "The Log Analytics workspace name"
  value       = module.subscription.log_analytics_workspace_name
}
