output "subscription_id" {
  description = "The ID of the created or managed subscription"
  # Returns subscription_id from either:
  # - Newly created subscription (azurerm_subscription.this[0].subscription_id) when use_existing_subscription=false
  # - Existing subscription (var.existing_subscription_id) when use_existing_subscription=true
  value = local.subscription_id
}

output "subscription_name" {
  description = "The name of the subscription"
  # For created subscriptions: returns the resource-generated name
  # For existing subscriptions: returns the subscription_name provided in variables
  # (Note: azurerm doesn't have subscription.name property, so we use input variable for existing subscriptions)
  value = var.use_existing_subscription ? var.subscription_name : azurerm_subscription.this[0].subscription_name
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

# DDoS Protection Plan output removed - not created when enable_ddos_protection = false

output "app_contributor_assignment_ids" {
  description = "Role assignment IDs for app Contributor groups"
  value       = [for ra in azurerm_role_assignment.app_contributor : ra.id]
}

output "finops_reader_assignment_ids" {
  description = "Role assignment IDs for FinOps Reader groups"
  value       = [for ra in azurerm_role_assignment.finops_reader : ra.id]
}
# Networking Outputs
output "spoke_vnet_id" {
  description = "The ID of the spoke virtual network"
  value       = try(azurerm_virtual_network.spoke[0].id, null)
}

output "spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  value       = try(azurerm_virtual_network.spoke[0].name, null)
}

output "app_subnet_id" {
  description = "The ID of the application subnet"
  value       = try(azurerm_subnet.app[0].id, null)
}

output "aks_subnet_id" {
  description = "The ID of the AKS subnet"
  value       = try(azurerm_subnet.aks[0].id, null)
}

output "database_subnet_id" {
  description = "The ID of the database subnet"
  value       = try(azurerm_subnet.database[0].id, null)
}

output "functions_subnet_id" {
  description = "The ID of the Azure Functions subnet"
  value       = try(azurerm_subnet.functions[0].id, null)
}

output "private_endpoints_subnet_id" {
  description = "The ID of the private endpoints subnet"
  value       = try(azurerm_subnet.private_endpoints[0].id, null)
}

output "app_nsg_id" {
  description = "The ID of the application NSG"
  value       = try(azurerm_network_security_group.app[0].id, null)
}

output "database_nsg_id" {
  description = "The ID of the database NSG"
  value       = try(azurerm_network_security_group.database[0].id, null)
}

output "app_route_table_id" {
  description = "The ID of the application route table"
  value       = try(azurerm_route_table.app[0].id, null)
}

output "database_route_table_id" {
  description = "The ID of the database route table"
  value       = try(azurerm_route_table.database[0].id, null)
}

output "keyvault_private_endpoint_id" {
  description = "The ID of the Key Vault private endpoint"
  value       = try(azurerm_private_endpoint.keyvault[0].id, null)
}

output "storage_private_endpoint_id" {
  description = "The ID of the Storage Account private endpoint"
  value       = try(azurerm_private_endpoint.storage[0].id, null)
}

output "sqldb_private_endpoint_id" {
  description = "The ID of the SQL Database private endpoint"
  value       = try(azurerm_private_endpoint.sqldb[0].id, null)
}

output "vnet_peering_id" {
  description = "The ID of the VNet peering to hub"
  value       = try(azurerm_virtual_network_peering.spoke_to_hub[0].id, null)
}