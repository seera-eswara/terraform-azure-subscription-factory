module "subscription" {
  source = "./modules/subscription"

  providers = {
    azurerm.subscription = azurerm.subscription
  }

  subscription_name   = var.subscription_name
  management_group_id = data.terraform_remote_state.landing_zone.outputs.corp_mg_id
  billing_scope_id    = var.billing_scope_id
  owners              = var.owners
  location            = var.location
  environment         = var.environment
}
