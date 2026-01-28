Automatically create new Azure subscriptions that are:

Placed in the correct Management Group

Have baseline policies applied

Have RBAC assigned

Are ready for app teams with zero manual steps

This is cloud-owned, not app-owned.


Request (YAML / PR / Form)
        ↓
Subscription Factory Pipeline
        ↓
Azure Subscription Created
        ↓
Move to Correct MG
        ↓
Apply Policies + Blueprints
        ↓
Assign RBAC
        ↓
Return Subscription ID


terraform-azure-subscription-factory/
├── .github/
│   └── workflows/
│       └── subscription-vending.yml
├── modules/
│   └── subscription/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
├── requests/
│   ├── dev/
│   │   └── app1.yaml
│   ├── test/
│   └── prod/
├── environments/
│   ├── dev/
│   ├── test/
│   └── prod/
└── README.md
