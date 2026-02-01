# Reference landing zone outputs for management group IDs
data "terraform_remote_state" "landing_zone" {
  backend = "azurerm"

  config = {
    resource_group_name  = var.landingzone_state_resource_group
    storage_account_name = var.landingzone_state_storage_account
    container_name       = var.landingzone_state_container
    key                  = var.landingzone_state_key
  }
}

# Get Applications MG from landing zone to use as parent for app MGs
data "azurerm_management_group" "applications" {
  name = "applications"
}

# Try to resolve app-specific management group
# If it doesn't exist, the module below will create it
data "azurerm_management_group" "app_mg" {
  name = "mg-${lower(var.app_code)}"

  # This might fail if MG doesn't exist yet, which is OK
  # The module.app_management_group below will create it
  
  count = 0  # Disabled - module creates it instead
}
