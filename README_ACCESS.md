# Group-based Access in Subscription Factory

Assign RBAC to Azure AD groups by display name:

- `app_contributor_groups`: App team access (Contributor)
- `finops_reader_groups`: Finance access (Reader)

Example `terraform.tfvars`:

```
app_contributor_groups = ["app1-contributors", "app1-operators"]
finops_reader_groups   = ["finops-readers"]
```

Groups are resolved via the `azuread` provider and bound to the new subscription scope.
Membership changes happen in Azure AD, not Terraform.
