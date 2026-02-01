# Reference landing zone outputs for management group IDs
data "terraform_remote_state" "landing_zone" {
  backend = "azurerm"

  config = {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "tfstatelzqiaypb"
    container_name       = "tfstate"
    key                  = "landingzone.tfstate"
  }
}

data "azurerm_client_config" "current" {}

# Try to resolve app-specific management group
# If it doesn't exist, the module below will create it
data "azurerm_management_group" "app_mg" {
  name = "mg-${lower(var.app_code)}"

  # This might fail if MG doesn't exist yet, which is OK
  # The module.app_management_group below will create it
  
  count = 0  # Disabled - module creates it instead
}
