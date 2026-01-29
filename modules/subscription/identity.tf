# ============================================================================
# Managed Identities for Application
# ============================================================================
# Create application-level managed identities for secure authentication
# and reduce credential management burden
#
# COST: FREE (No additional cost for managed identities)
#
# BENEFITS:
# - Eliminates need for service principal credentials
# - Azure handles identity lifecycle automatically
# - Integrates seamlessly with Azure RBAC
# - No secrets to rotate manually
#
# TYPES:
# 1. System-assigned: Lifecycle tied to resource (created when resource created)
# 2. User-assigned: Standalone resources, multiple resources can use same identity
#
# We create User-Assigned because:
# - Can be referenced across multiple app resources
# - Lifecycle independent from any single resource
# - Easier to test and manage in development
# ============================================================================

# User-assigned managed identity for the application
# This identity can be assigned to VMs, App Service, AKS, Functions, etc.
resource "azurerm_user_assigned_identity" "app_identity" {
  count = var.enable_app_identity ? 1 : 0

  resource_group_name = azurerm_resource_group.baseline.name
  location            = var.location
  name                = "uai-${var.app_code}-${var.environment}"

  tags = merge(
    var.tags,
    {
      Purpose = "Application Managed Identity"
      Module  = "identity"  # Module-level tag for cost tracking
    }
  )
}

# Output the managed identity for app resources to use
output "app_managed_identity_id" {
  value       = try(azurerm_user_assigned_identity.app_identity[0].id, null)
  description = "Resource ID of the user-assigned managed identity for this app"
}

output "app_managed_identity_principal_id" {
  value       = try(azurerm_user_assigned_identity.app_identity[0].principal_id, null)
  description = "Principal ID of the managed identity (use for RBAC assignments)"
}

output "app_managed_identity_client_id" {
  value       = try(azurerm_user_assigned_identity.app_identity[0].client_id, null)
  description = "Client ID of the managed identity (use in application code)"
}

# FUTURE: Key Vault Access Policy Integration
# ============================================================================
# When your Key Vault is created/referenced, add access policy like:
#
# resource "azurerm_key_vault_access_policy" "app_identity" {
#   count = var.enable_app_identity && var.keyvault_id != null ? 1 : 0
#
#   key_vault_id       = var.keyvault_id
#   tenant_id          = data.azurerm_client_config.current.tenant_id
#   object_id          = azurerm_user_assigned_identity.app_identity[0].principal_id
#   secret_permissions = ["Get", "List"]
#   key_permissions    = ["Get", "List"]
# }
#
# This allows your app (using this identity) to read secrets and keys from Key Vault
# ============================================================================
