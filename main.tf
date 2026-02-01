module "naming" {
  source = "git::https://github.com/seera-eswara/terraform-azure-modules.git//modules/naming?ref=main"

  app_code    = var.app_code
  module      = var.module  # Pass module for subscription naming
  environment = var.environment
  location    = "eastus"
  instance    = var.instance != null ? var.instance : 1  # Default to 1 if not provided

  additional_tags = {
    SubscriptionPurpose = "App Team Subscription"
    BillingEntity       = var.billing_entity
  }
}

# Create app-specific management group if it doesn't exist
# This is created on-demand as part of subscription provisioning
# rather than requiring cloud team to manage it separately
module "app_management_group" {
  source = "git::https://github.com/seera-eswara/terraform-azure-modules.git//modules/app-management-group?ref=main"

  app_code                   = var.app_code
  parent_management_group_id = data.terraform_remote_state.landing_zone.outputs.applications_mg_id

  app_owners       = var.owners  # App team owners assigned to app MG
  app_contributors = var.app_contributors
}

module "subscription" {
  source = "./modules/subscription"

  providers = {
    azurerm.subscription = azurerm.subscription
  }

  app_code               = var.app_code
  subscription_name      = coalesce(var.subscription_name, module.naming.subscription)  # Use naming module if not provided
  management_group_id    = module.app_management_group.management_group_id
  billing_scope_id       = var.billing_scope_id
  owners                 = var.owners
  location               = var.location
  environment            = var.environment
  
  # Naming
  resource_group_name    = module.naming.names.resource_group
  law_name               = module.naming.names.log_analytics_workspace
  
  # Budget & Alerting
  monthly_budget         = var.monthly_budget
  budget_alert_threshold = var.budget_alert_threshold
  alert_emails           = var.alert_emails
  
  # Security
  enable_defender        = var.enable_defender
  enable_ddos_protection = var.enable_ddos_protection
  
  # Networking
  create_spoke_vnet                = var.create_spoke_vnet
  spoke_vnet_name                  = var.create_spoke_vnet ? "vnet-${var.app_code}-spoke-${var.environment}" : ""
  spoke_vnet_address_space         = var.spoke_vnet_address_space
  app_subnet_prefix                = var.app_subnet_prefix
  enable_aks_subnet                = var.enable_aks_subnet
  aks_subnet_prefix                = var.aks_subnet_prefix
  enable_database_subnet           = var.enable_database_subnet
  database_subnet_prefix           = var.database_subnet_prefix
  enable_functions_subnet          = var.enable_functions_subnet
  functions_subnet_prefix          = var.functions_subnet_prefix
  enable_private_endpoints_subnet  = var.enable_private_endpoints_subnet
  private_endpoints_subnet_prefix  = var.private_endpoints_subnet_prefix
  hub_vnet_id                      = var.hub_vnet_id
  hub_vnet_name                    = var.hub_vnet_name
  hub_vnet_address_space           = var.hub_vnet_address_space
  use_remote_gateway               = var.use_remote_gateway
  keyvault_id                      = var.keyvault_id
  storage_account_id               = var.storage_account_id
  sqldb_id                         = var.sqldb_id
  
  # Policies
  create_policy_assignments = var.create_policy_assignments
  allowed_regions           = var.allowed_regions
  required_tags             = var.required_tags
  
  # Existing subscription (for Pay-As-You-Go accounts)
  use_existing_subscription = var.subscription_id_override != null ? true : false
  existing_subscription_id  = var.subscription_id_override

  # RBAC group bindings
  app_contributor_groups  = var.app_contributor_groups
  finops_reader_groups    = var.finops_reader_groups
  
  # Diagnostics
  enable_diagnostic_settings      = var.enable_diagnostic_settings
  event_hub_authorization_rule_id = var.event_hub_authorization_rule_id
  
  # Identity
  enable_app_identity = var.enable_app_identity
  
  # Monitoring & Alerting
  enable_monitoring        = var.enable_monitoring
  alert_email_addresses    = var.alert_email_addresses
  webhook_url              = var.webhook_url
  
  # Tags
  tags                   = module.naming.tags

  # Ensure subscription is created after MG
  depends_on = [module.app_management_group]
}

