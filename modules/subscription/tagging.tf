# ============================================================================
# Tagging Strategy and Default Tags
# ============================================================================
# Enforce consistent tagging across the subscription for:
# - Cost allocation and chargeback by APP and INFRASTRUCTURE COMPONENT
# - Resource organization and discovery
# - Compliance and audit requirements
# - Operational management
#
# TAGGING STRATEGY:
# ============================================================================
#
# 1. APP-LEVEL resources (Subscription, MG, RBAC, Budget):
#    Tags:
#      - AppCode: Application identifier (e.g., rff, crm, erp)
#      - Environment, CostCenter, Owner, etc.
#    Query: az resource list --tag AppCode=rff
#
# 2. INFRASTRUCTURE-LEVEL resources (created by subscription factory):
#    Tags:
#      - AppCode: Application identifier (e.g., rff)
#      - InfraComponent: Infrastructure component name
#    
#    Components:
#      - InfraComponent=networking     (VNets, subnets, NSGs, route tables, private endpoints)
#      - InfraComponent=identity       (User-assigned managed identities)
#      - InfraComponent=diagnostics    (Log Analytics, diagnostic settings)
#      - InfraComponent=monitoring     (Action groups, alert rules)
#    
#    Query: az resource list --tag AppCode=rff --tag InfraComponent=networking
#           az resource list --tag AppCode=rff --tag InfraComponent=identity
#
# 3. MODULE-LEVEL resources (deployed by app teams):
#    NOTE: These are NOT created by subscription factory
#    Tags (to be applied by app teams when deploying their modules):
#      - AppCode: Application identifier (e.g., rff)
#      - ModuleCode: Business module identifier (e.g., frontend, backend, db)
#    
#    Modules:
#      - ModuleCode=frontend    (React/Angular, App Service, CDN, etc.)
#      - ModuleCode=backend     (Python/Node.js API, Azure Function, etc.)
#      - ModuleCode=db          (Azure SQL, Cosmos DB, PostgreSQL, etc.)
#    
#    Query: az resource list --tag AppCode=rff --tag ModuleCode=frontend
#           az resource list --tag AppCode=rff --tag ModuleCode=backend
#           az resource list --tag AppCode=rff --tag ModuleCode=db
#
# COST: FREE - No additional cost for tags
#
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

  # Infrastructure-level tags (used for resources created by subscription factory)
  # Includes BOTH AppCode and InfraComponent for granular cost tracking
  infra_networking_tags = merge(
    local.app_tags,
    {
      InfraComponent = "networking"  # For VNets, subnets, NSGs, private endpoints
    }
  )

  infra_identity_tags = merge(
    local.app_tags,
    {
      InfraComponent = "identity"  # For managed identities
    }
  )

  infra_diagnostics_tags = merge(
    local.app_tags,
    {
      InfraComponent = "diagnostics"  # For Log Analytics, diagnostic settings
    }
  )

  infra_monitoring_tags = merge(
    local.app_tags,
    {
      InfraComponent = "monitoring"  # For action groups, alert rules
    }
  )
}

# Output for documentation purposes
output "standard_tags" {
  value       = local.app_tags
  description = "Standard tags applied to app-level resources"
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
    infra_level_tags = {
      "AppCode"          = "Application identifier"
      "InfraComponent"   = "networking | identity | diagnostics | monitoring"
      "Environment"      = "dev, stage, prod"
      "CostCenter"       = "Billing entity"
      "Owner"            = "App code"
      "ManagedBy"        = "Terraform"
    }
    module_level_tags = {
      "AppCode"    = "Application identifier (e.g., rff)"
      "ModuleCode" = "Business module (e.g., frontend, backend, db)"
      note         = "Applied by app teams when deploying their modules - NOT by subscription factory"
    }
  }
  description = "Complete tagging structure for cost allocation and tracking"
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
    ========================================
    COST TRACKING STRUCTURE FOR ${upper(var.app_code)} APPLICATION
    ========================================
    
    LAYER 1: APP-LEVEL RESOURCES
    ========================================
    Resources: Subscription, Management Group, RBAC, Budget, Policies
    Tags: AppCode=${var.app_code}
    
    Query total app cost:
    az resource list --tag AppCode=${var.app_code} --query "[].{Name:name, Type:type, Tags:tags}"
    
    
    LAYER 2: INFRASTRUCTURE COMPONENTS (managed by subscription factory)
    ========================================
    
    NETWORKING Infrastructure:
    - Virtual Networks (VNets)
    - Subnets (app, aks, database, functions, private-endpoints)
    - Network Security Groups (NSGs)
    - Route Tables
    - Private Endpoints (for shared services: KeyVault, Storage, SQL DB)
    
    Tags: AppCode=${var.app_code}, InfraComponent=networking
    Query: az resource list --tag AppCode=${var.app_code} --tag InfraComponent=networking
    Typical cost: $50-200/month (depends on data transfer, private endpoints)
    
    
    IDENTITY Infrastructure:
    - User-Assigned Managed Identities
    - RBAC Role Assignments
    
    Tags: AppCode=${var.app_code}, InfraComponent=identity
    Query: az resource list --tag AppCode=${var.app_code} --tag InfraComponent=identity
    Cost: FREE (managed identities have no direct cost)
    
    
    DIAGNOSTICS Infrastructure:
    - Log Analytics Workspace
    - Diagnostic Settings
    - Activity Log Streaming
    
    Tags: AppCode=${var.app_code}, InfraComponent=diagnostics
    Query: az resource list --tag AppCode=${var.app_code} --tag InfraComponent=diagnostics
    Typical cost: $0.50-2/day (~$15-60/month)
    
    
    MONITORING Infrastructure:
    - Action Groups
    - Alert Rules
    - Metrics
    
    Tags: AppCode=${var.app_code}, InfraComponent=monitoring
    Query: az resource list --tag AppCode=${var.app_code} --tag InfraComponent=monitoring
    Cost: FREE (action groups and basic alerts are free)
    
    
    LAYER 3: APPLICATION MODULES (deployed by app teams)
    ========================================
    
    These resources are NOT created by subscription factory.
    App teams deploy them and should tag with AppCode + ModuleCode.
    
    FRONTEND Module (React/Angular):
    - App Service / Static Web App
    - CDN
    - Application Insights
    
    Tags: AppCode=${var.app_code}, ModuleCode=frontend
    Query: az resource list --tag AppCode=${var.app_code} --tag ModuleCode=frontend
    Typical cost: $10-100/month
    
    
    BACKEND Module (Python/Node.js):
    - App Service / Azure Function / Container Instances / AKS
    - API Management (optional)
    - Redis Cache (optional)
    
    Tags: AppCode=${var.app_code}, ModuleCode=backend
    Query: az resource list --tag AppCode=${var.app_code} --tag ModuleCode=backend
    Typical cost: $50-500/month (depending on scale/compute)
    
    
    DATABASE Module (Azure SQL / Cosmos DB):
    - Azure SQL Database / Managed Instance
    - Cosmos DB
    - Backup & Restore
    
    Tags: AppCode=${var.app_code}, ModuleCode=db
    Query: az resource list --tag AppCode=${var.app_code} --tag ModuleCode=db
    Typical cost: $50-1000/month (database is often highest cost)
    
    
    ========================================
    COMPLETE COST BREAKDOWN EXAMPLE
    ========================================
    
    RFF Application (${var.app_code}) Total Monthly Billing:
    
    Infrastructure:
      - Networking (VNets, NSGs, private endpoints):  $75
      - Identity (Managed IDs):                       $0
      - Diagnostics (Log Analytics):                 $20
      - Monitoring (Actions, Alerts):                $0
      Subtotal Infrastructure:                       $95
    
    Application Modules (to be tracked by app teams):
      - Frontend (React, App Service, CDN):          $30
      - Backend (Python API, App Service):           $120
      - Database (Azure SQL):                        $300
      Subtotal Modules:                              $450
    
    GRAND TOTAL:                                     $545/month
    
    
    ========================================
    IMPORTANT NOTES FOR APP TEAMS
    ========================================
    
    1. WHEN DEPLOYING APPLICATION MODULES:
       Always tag resources with:
       - AppCode = ${var.app_code}
       - ModuleCode = frontend|backend|db|etc
       - Environment = ${var.environment}
       - Owner = Team name
    
    2. COST OPTIMIZATION:
       - Monitor InfraComponent costs monthly
       - Private endpoints add ~$5-10/month each
       - Log Analytics is ~$0.50-2/day - monitor data retention
    
    3. COST ALERTS:
       Budget alerts are set for: \$${var.monthly_budget}/month at ${var.budget_alert_threshold}% threshold
       If budget > 0, alerts will trigger at this level
    
    4. QUERY EXAMPLES:
       # Total cost by app
       az resource list --tag AppCode=${var.app_code}
       
       # Cost by infrastructure component
       az resource list --tag AppCode=${var.app_code} --tag InfraComponent=networking
       
       # Cost by business module
       az resource list --tag AppCode=${var.app_code} --tag ModuleCode=frontend
       
       # Find all resources in subscription
       az resource list --subscription ${data.azurerm_client_config.tags.subscription_id}
  EOT
  description = "Comprehensive guide for tracking costs by AppCode, InfraComponent, and ModuleCode"
}


