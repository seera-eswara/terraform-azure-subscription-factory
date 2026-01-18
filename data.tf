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

# Resolve team management group under LandingZones using app_code
data "azurerm_management_group" "team" {
  name = "${var.management_group_prefix}-${var.app_code}"
}
