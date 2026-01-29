# ============================================================================
# COST OPTIMIZATION: Defender Resources Disabled
# ============================================================================
# These resources are commented out by default to preserve Azure free credits
# 
# COST BREAKDOWN:
# - Defender for VMs: $7/month per VM
# - Defender for Storage: $0.02 per 100K transactions
# - Defender for SQL: $15/month per database
# - Defender for Kubernetes: $7/month per cluster
#
# TOTAL: Can exceed $500+/month with full deployment
#
# WHEN TO ENABLE (Production Environment):
# 1. Set variable.enable_defender = true in terraform.tfvars
# 2. Ensure you have budget allocated (~$500+/month)
# 3. Re-run: terraform plan and terraform apply
# 4. Monitor in Azure Cost Management + Billing
#
# LEARNING REFERENCE:
# Keep this code commented for interview prep. Understand what each
# resource does and when it would be enabled in production.
# ============================================================================

# Enable Microsoft Defender for Cloud on subscription
# Uncomment when enable_defender = true
# resource "azurerm_security_center_subscription_pricing" "defender_vms" {\n  count = var.enable_defender ? 1 : 0

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
