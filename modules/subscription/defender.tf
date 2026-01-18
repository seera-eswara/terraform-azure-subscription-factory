# Enable Microsoft Defender for Cloud on subscription
resource "azurerm_security_center_subscription_pricing" "defender_vms" {
  count = var.enable_defender ? 1 : 0

  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  count = var.enable_defender ? 1 : 0

  tier          = "Standard"
  resource_type = "StorageAccounts"
}

resource "azurerm_security_center_subscription_pricing" "defender_databases" {
  count = var.enable_defender ? 1 : 0

  tier          = "Standard"
  resource_type = "SqlServers"
}

resource "azurerm_security_center_subscription_pricing" "defender_k8s" {
  count = var.enable_defender ? 1 : 0

  tier          = "Standard"
  resource_type = "KubernetesService"
}

# Enable auto-provisioning of monitoring agent
resource "azurerm_security_center_auto_provisioning" "defender_agents" {
  count = var.enable_defender ? 1 : 0

  auto_provision = "On"
}

# Set security center contact info
resource "azurerm_security_center_security_alert_policy" "main" {
  resource_group_name = azurerm_resource_group.baseline.name

  alerts_to_admins = true
}
