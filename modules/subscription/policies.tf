# Apply policies to new subscriptions created by the factory
# Policies are inherited from parent management group
# This file handles additional app-specific policy assignments

data "azurerm_policy_definition" "allowed_regions" {
  name = "allowed-regions"
}

data "azurerm_policy_definition" "require_tags" {
  name = "require-tags"
}

# Assign allowed regions policy to new app subscriptions
# This ensures apps can only deploy to approved regions
resource "azurerm_management_group_policy_assignment" "app_allowed_regions" {
  count = var.create_policy_assignments ? 1 : 0

  name                 = "${var.app_code}-allowed-regions"
  policy_definition_id = data.azurerm_policy_definition.allowed_regions.id
  management_group_id  = var.management_group_id

  parameters = jsonencode({
    allowedLocations = {
      value = var.allowed_regions
    }
  })

  description = "Restrict deployments to approved regions for ${var.app_code}"
  display_name = "${var.app_code}: Allowed Regions"
}

# Assign tagging enforcement policy
# Ensures all resources have required tags
resource "azurerm_management_group_policy_assignment" "app_require_tags" {
  count = var.create_policy_assignments ? 1 : 0

  name                 = "${var.app_code}-require-tags"
  policy_definition_id = data.azurerm_policy_definition.require_tags.id
  management_group_id  = var.management_group_id

  parameters = jsonencode({
    requiredTags = {
      value = [
        "Environment",
        "CostCenter",
        "Owner",
        "Application",
        "CreatedBy"
      ]
    }
  })

  description = "Require standard tags on all resources for ${var.app_code}"
  display_name = "${var.app_code}: Required Tags"
}

# Output policy assignment status for audit
output "policy_assignments" {
  value = {
    allowed_regions = var.create_policy_assignments ? azurerm_management_group_policy_assignment.app_allowed_regions[0].id : null
    required_tags   = var.create_policy_assignments ? azurerm_management_group_policy_assignment.app_require_tags[0].id : null
  }
  description = "IDs of policy assignments applied to the subscription"
}

output "inherited_policies" {
  value = {
    note = "The following policies are inherited from parent management group:"
    policies = [
      "Allowed VM SKUs",
      "Naming Convention",
      "Cost Controls (if configured)"
    ]
  }
  description = "Policies inherited from parent management group"
}
