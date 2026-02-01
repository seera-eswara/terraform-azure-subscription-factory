# Group-based subscription RBAC assignments

# Resolve Azure AD groups by display name
# Contributor groups
data "azuread_group" "app_contributor" {
  for_each     = toset(var.app_contributor_groups)
  display_name = each.key
}

# Reader groups (e.g., FinOps)
data "azuread_group" "reader" {
  for_each     = toset(var.finops_reader_groups)
  display_name = each.key
}

# Create a local map to avoid for_each issues during import
locals {
  app_contributor_groups = { for name in var.app_contributor_groups : name => data.azuread_group.app_contributor[name].id }
  finops_reader_groups   = { for name in var.finops_reader_groups : name => data.azuread_group.reader[name].id }
}

# Role definitions
data "azurerm_role_definition" "contributor" {
  name  = "Contributor"
  scope = "/"
}

data "azurerm_role_definition" "reader" {
  name  = "Reader"
  scope = "/"
}

# Assign Contributor to app groups at subscription scope
# scope must be the full subscription path for role assignments to work correctly
# Using local.subscription_id which handles both:
# - New subscriptions created via azurerm_subscription resource
# - Existing subscriptions passed via subscription_id_override variable
resource "azurerm_role_assignment" "app_contributor" {
  for_each = local.app_contributor_groups
  
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = data.azurerm_role_definition.contributor.id
  principal_id       = each.value
}

# Assign Reader to FinOps groups at subscription scope
# scope must be the full subscription path for role assignments to work correctly
# Using local.subscription_id which handles both:
# - New subscriptions created via azurerm_subscription resource
# - Existing subscriptions passed via subscription_id_override variable
resource "azurerm_role_assignment" "finops_reader" {
  for_each = local.finops_reader_groups
  
  scope              = "/subscriptions/${local.subscription_id}"
  role_definition_id = data.azurerm_role_definition.reader.id
  principal_id       = each.value
}
