module "naming" {
  source = "git::https://github.com/seera-eswara/terraform-azure-modules.git//modules/naming?ref=main"

  app_code    = var.app_code
  environment = var.environment
  location    = "eastus"

  additional_tags = {
    SubscriptionPurpose = "App Team Subscription"
    BillingEntity       = var.billing_entity
  }
}

module "subscription" {
  source = "./modules/subscription"

  providers = {
    azurerm.subscription = azurerm.subscription
  }

  subscription_name      = var.subscription_name
  management_group_id    = data.azurerm_management_group.team.id
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
  
  # Tags
  tags                   = module.naming.tags
}
