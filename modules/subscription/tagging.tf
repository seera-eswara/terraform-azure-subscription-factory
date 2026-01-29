# ============================================================================
# Tagging Strategy and Default Tags
# ============================================================================
# Enforce consistent tagging across the subscription for:
# - Cost allocation and chargeback by APP and MODULE
# - Resource organization and discovery
# - Compliance and audit requirements
# - Operational management
#
# TAGGING STRATEGY:
# 1. APP-LEVEL resources (Subscription, MG, RBAC):
#    - AppCode: Application code
#    - Environment, CostCenter, Owner, etc.
#
# 2. MODULE-LEVEL resources (Networking, Identity, Monitoring, Diagnostics):
#    - AppCode: Application code
#    - Module: Module name (networking, identity, monitoring, diagnostics)
#    - This allows tracking which MODULE within APP consumes most resources
#
# COST: FREE - No additional cost for tags
#
# TAGS INCLUDED:
# - Environment: dev, stage, prod (for environment-specific operations)
# - CostCenter: For billing and chargeback
# - Owner: For accountability and escalation
# - AppCode: App code for cost allocation
# - Module: Module name for module-level resource tracking
# - ManagedBy: "Terraform" for IaC tracking
# - CreatedBy: Team/person for audit
# - CreationDate: When resource was provisioned
# ============================================================================

# Get current client config for tags
data "azurerm_client_config" "tags" {}

# Local variables for app-level tags (used for subscription, MG, RBAC resources)
locals {
  app_tags = {
    Environment  = var.environment
    CostCenter   = var.billing_entity
    Owner        = var.app_code
    AppCode      = var.app_code
    ManagedBy    = "Terraform"
    CreatedBy    = "SubscriptionFactory"
    CreationDate = timestamp()
  }

  # Module-level tags (used for resources created at module level)
  # Includes BOTH AppCode and Module for granular cost tracking
  module_tags = merge(
    local.app_tags,
    {
      Module = "subscription-module"  # Generic - will be overridden in specific files
    }
  )
}

# Output for documentation purposes
output "standard_tags" {
  value       = local.app_tags
  description = "Standard tags applied to app-level resources"
}

output "module_tags" {
  value       = local.module_tags
  description = "Tags applied to module-level resources (includes Module tag for cost tracking)"
}

output "tagging_structure" {
  value = {
    app_level_tags = {
      "AppCode"      = "Application identifier (e.g., rff, crm)"
      "Environment"  = "dev, stage, prod"
      "CostCenter"   = "Billing entity"
      "Owner"        = "App code"
      "ManagedBy"    = "Terraform"
    }
    module_level_tags = {
      "AppCode"      = "Application identifier"
      "Module"       = "Module name (networking, identity, monitoring, diagnostics)"
      "Environment"  = "dev, stage, prod"
      "CostCenter"   = "Billing entity"
      "Owner"        = "App code"
      "ManagedBy"    = "Terraform"
    }
  }
  description = "Tagging structure for cost allocation and tracking"
}

output "tagging_policy_status" {
  value = {
    policy_name = "Require Tags"
    assignment  = "app_require_tags"
    enforced    = var.create_policy_assignments
    required_tags = [
      "Environment",
      "CostCenter",
      "Owner",
      "AppCode",
      "CreatedBy"
    ]
  }
  description = "Details of tag enforcement policy (see policies.tf)"
}

output "cost_tracking_guide" {
  value = <<-EOT
    COST TRACKING STRUCTURE FOR ${upper(var.app_code)} APPLICATION
    
    ========================================
    APP-LEVEL RESOURCES (AppCode tag only)
    ========================================
    - Subscription
    - Management Group
    - RBAC assignments
    - Budget alerts
    - Policies
    
    Query: az resource list --tag AppCode=${var.app_code} --query "[].{Name:name, AppCode:tags.AppCode, Cost:???}"
    
    ========================================
    MODULE-LEVEL RESOURCES (AppCode + Module tag)
    ========================================
    Networking Module:
      - Virtual Networks
      - Subnets
      - Network Security Groups
      - Route Tables
      - Private Endpoints
    
    Query: az resource list --tag AppCode=${var.app_code} --tag Module=networking
    
    Identity Module:
      - User-Assigned Managed Identities
      - Service Principal assignments
    
    Query: az resource list --tag AppCode=${var.app_code} --tag Module=identity
    
    Diagnostics Module:
      - Log Analytics Workspace
      - Diagnostic settings
      - Storage accounts (if configured)
    
    Query: az resource list --tag AppCode=${var.app_code} --tag Module=diagnostics
    
    Monitoring Module:
      - Action Groups
      - Alert Rules
      - Metrics
    
    Query: az resource list --tag AppCode=${var.app_code} --tag Module=monitoring
    
    ========================================
    COST ALLOCATION EXAMPLE
    ========================================
    Monthly billing breakdown:
    
    APP-LEVEL COSTS (shared across all modules):
      rff subscription: $50/month
      rff management group: $0 (free)
      rff policies: $0 (free)
      Total: $50
    
    MODULE-LEVEL COSTS (trackable by module):
      rff + networking: $120/month (VNets, subnets, NSGs, peering)
      rff + identity: $0/month (managed identities are free)
      rff + diagnostics: $10/month (Log Analytics)
      rff + monitoring: $5/month (Action groups, alerts)
      Total: $135
    
    GRAND TOTAL (rff app): $185/month
    
    This breakdown helps identify which MODULE is the cost driver.
  EOT
  description = "Guide for tracking costs by AppCode and Module"
}

