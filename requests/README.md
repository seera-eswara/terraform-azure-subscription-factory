# Subscription Requests

This directory contains YAML files that define subscription creation requests.

## How It Works

When you create a subscription request:
1. **App Management Group** is automatically created (if it doesn't exist) under the `Applications` MG
2. **Subscription** is created and assigned to the app MG  
3. **Baseline resources** are provisioned (Resource Group, Log Analytics, etc.)
4. **Policies** are inherited from the parent MGs

This keeps `terraform-azure-landingzone` stable (cloud team focused) while allowing app teams to self-serve subscriptions via the factory.

## Structure

```
requests/
├── dev/           # Development subscriptions
│   ├── rff-react.yaml        (RFF app, React module, Dev environment)
│   ├── app1.yaml
│   └── app2.yaml
├── staging/       # Staging subscriptions
│   ├── rff-react.yaml        (RFF app, React module, Staging environment)
│   └── ...
└── prod/          # Production subscriptions
    ├── rff-react.yaml        (RFF app, React module, Prod environment)
    └── ...
```

## Architecture

```
terraform-azure-landingzone (Cloud Team)
  └── Creates: Root MG structure
      └── Applications MG (parent for all app MGs)

                    ↓ (outputs Applications MG ID)

terraform-azure-subscription-factory (App Teams)
  ├── Creates: MG-{APP_CODE} under Applications
  │           (e.g., MG-RFF via module.app_management_group)
  └── Creates: {APP}-{MODULE}-{ENV} subscriptions
              (assigned to MG-{APP_CODE})
```

## Naming Convention

### Subscription Request Filename
```
{app-code-lowercase}-{module-lowercase}.yaml

Examples:
- rff-react.yaml       → RFF app, React module
- app1-api.yaml        → APP1 app, API module  
- payment-ml.yaml      → PAYMENT app, ML module
```

### What Gets Created

**Management Group**: `MG-{APP_CODE}` (created once per app, reused for all modules)
- Resource name: `mg-rff`, `mg-abc`, etc.

**Subscriptions**: `{APP_CODE}-{MODULE}-{ENV}` (one per request file)
- Examples: `RFF-REACT-DEV`, `RFF-REACT-STG`, `RFF-REACT-PRD`

## YAML File Format

### Required Fields

```yaml
subscription_name: rff-react-dev          # Lowercase, hyphens only
environment: dev                          # dev, stage, prod, qa, uat, sit
app_code: RFF                             # 3-10 uppercase chars (creates MG if needed)
module: REACT                             # Technology/functional area

owners:                                   # App team - assigned to subscription AND app MG
  - 11111111-1111-1111-1111-111111111111  # Get via: az ad user show --id <email>
  - 22222222-2222-2222-2222-222222222222
```

### Optional Fields

```yaml
# Additional RBAC at app MG level
app_contributors:                         # Secondary owners for app MG
  - 33333333-3333-3333-3333-333333333333

# Billing & Cost Tracking
billing_entity: RFF-TEAM                  # Team or department code
cost_center: CC-RFF-001                   # Cost center for chargeback
application_id: rff-react                 # Application identifier

# Optional: Specific resource group settings
resource_group_name: rg-rff-react-dev    # Custom RG name (auto-generated if omitted)
location: eastus                          # Azure region (default: eastus)

# Optional: Enablements
enable_ddos_protection: false             # DDoS Protection Plan

# Optional: Tags applied to resources
tags:
  Environment: dev
  Owner: rff-team@company.com
  CreatedBy: terraform
```

## Example Files

### Development Environment

**`dev/rff-react.yaml`**:
```yaml
subscription_name: rff-react-dev
environment: dev
app_code: RFF
module: REACT

owners:
  - 11111111-1111-1111-1111-111111111111
  - 22222222-2222-2222-2222-222222222222

billing_entity: RFF-TEAM
cost_center: CC-RFF-001
application_id: rff-react
location: eastus
```

### Staging Environment

**`staging/rff-react.yaml`**:
```yaml
subscription_name: rff-react-stg
environment: stage
app_code: RFF
module: REACT

owners:
  - 11111111-1111-1111-1111-111111111111
  - 22222222-2222-2222-2222-222222222222

billing_entity: RFF-TEAM
cost_center: CC-RFF-001
application_id: rff-react
location: eastus
```

### Production Environment

**`prod/rff-react.yaml`**:
```yaml
subscription_name: rff-react-prd
environment: prod
app_code: RFF
module: REACT

owners:
  - 11111111-1111-1111-1111-111111111111
  - 22222222-2222-2222-2222-222222222222

billing_entity: RFF-TEAM
cost_center: CC-RFF-001
application_id: rff-react
location: eastus
enable_ddos_protection: true  # Production only
```

## Provisioning Process

### Step 1: Create/Update YAML files

Place YAML files in the appropriate environment directories:
- `requests/dev/rff-react.yaml`
- `requests/staging/rff-react.yaml`
- `requests/prod/rff-react.yaml`

### Step 2: Provision Subscriptions (and App MG if needed)

```bash
cd terraform-azure-subscription-factory

# Update variable values from YAML
terraform init
terraform plan -var-file="path/to/variables.tfvars"
terraform apply -var-file="path/to/variables.tfvars"
```

Or if using a pipeline that auto-discovers YAML files, simply push and let CI/CD handle it.

### Step 3: Verify

```bash
# List subscriptions
az account subscription list --query "[?displayName=='rff-react-dev']"

# Check app MG
az account management-group show --name mg-rff

# Verify subscription is in correct MG
az account management-group subscription show --name mg-rff --subscription rff-react-dev
```

## Key Points

### App Code Rules
- `app_code: RFF` → creates management group `MG-RFF` under Applications
- Management group is created **once** on first subscription request for that app
- Subsequent subscriptions for same app code reuse the same MG
- Must match existing MG if using an app that already has one

### Owners = App MG + Subscription
The `owners` list is assigned to:
1. **Subscription level** - Full owner permissions on subscription
2. **App MG level** - Can manage app MG and all subscriptions within it

### Multiple Modules per App
Same app can have multiple modules:
```
MG-RFF (created once)
├── RFF-REACT-DEV (subscription)
├── RFF-REACT-STG (subscription)
├── RFF-REACT-PRD (subscription)
├── RFF-API-DEV (subscription)
├── RFF-API-STG (subscription)
└── RFF-API-PRD (subscription)
```

### Environment Values
Valid environment values (enforced by validation):
- `dev` (Development)
- `stage` (Staging)  
- `prod` (Production)
- `qa` (Quality Assurance)
- `uat` (User Acceptance Testing)
- `sit` (System Integration Testing)

## Getting Principal IDs

For owners and app_contributors fields, get AAD object IDs:

```bash
# For a user
az ad user show --id john.doe@company.com --query id

# For a group
az ad group show --group "rff-team" --query id

# List multiple users
az ad user list --query "[].{name:userPrincipalName, id:id}"
```

## Post-Provisioning

After Terraform creates subscriptions:

1. **Verify subscription exists**:
   ```bash
   az account subscription list --query "[?displayName=='rff-react-dev']"
   ```

2. **Check app MG was created**:
   ```bash
   az account management-group show --name mg-rff
   ```

3. **Verify assignment**:
   ```bash
   az account management-group subscription show --name mg-rff --subscription rff-react-dev
   ```

4. **Check inherited policies**:
   ```bash
   az policy assignment list --scope "/providers/Microsoft.Management/managementGroups/mg-rff"
   ```

5. **Verify RBAC**:
   ```bash
   az role assignment list --scope "/providers/Microsoft.Management/managementGroups/mg-rff"
   ```

6. **Share with app team**:
   - Subscription ID
   - Resource Group name
   - Management Group: MG-RFF
   - Inherited Policies (from Applications and MG-RFF)
   - Owner assignments

## Troubleshooting

### Subscription Not Created
```
Error: subscription name 'rff-react-dev' already exists
```
**Solution**: Choose a unique subscription name

### App MG Not Created
```
Error: Failed to get Applications MG from landing zone
```
**Solution**: Verify landing zone was deployed and outputs are accessible

### Principal ID Invalid
```
Error: principal 11111111-1111-1111-1111-111111111111 not found
```
**Solution**: Verify the principal ID exists in your AAD tenant:
```bash
az ad user show --id <principal-id> 2>/dev/null || az ad group show --id <principal-id>
```

### YAML Not Parsed
```
Error: invalid YAML syntax
```
**Solution**: Validate YAML formatting (spacing, quotes, colons)

## Related Documentation

- [APP_MANAGEMENT_GROUP_GUIDE.md](../../APP_MANAGEMENT_GROUP_GUIDE.md) - Complete architecture guide
- [ARCHITECTURE_INTEGRATION.md](../../ARCHITECTURE_INTEGRATION.md) - Integration details
- [QUICK_REFERENCE.md](../../QUICK_REFERENCE.md) - Quick reference guide
- [IMPLEMENTATION_SUMMARY.md](../../IMPLEMENTATION_SUMMARY.md) - What was implemented
- [terraform-azure-modules/modules/app-management-group/README.md](../../terraform-azure-modules/modules/app-management-group/README.md) - Module details


## Naming Convention

Subscription request filenames should follow the pattern:
```
{app-code-lowercase}-{module-lowercase}.yaml
```

Examples:
- `rff-react.yaml` - RFF app, React module
- `app1-api.yaml` - APP1 app, API module
- `payment-ml.yaml` - PAYMENT app, ML module

## YAML File Format

### Required Fields

```yaml
subscription_name: rff-react-dev          # Lowercase, hyphens only
environment: dev                          # dev, stage, prod, qa, uat, sit
app_code: RFF                             # 3-10 uppercase alphanumeric (matches MG)
module: REACT                             # Technology/functional area

owners:                                   # REQUIRED: App team owners
  - 11111111-1111-1111-1111-111111111111  # Get via: az ad user show --id <email>
  - 22222222-2222-2222-2222-222222222222
```

### Optional Fields

```yaml
# Billing & Cost Tracking
billing_entity: RFF-TEAM                  # Team or department code
cost_center: CC-RFF-001                   # Cost center for chargeback
application_id: rff-react                 # Application identifier

# Optional: Specific resource group settings
resource_group_name: rg-rff-react-dev    # Custom RG name (auto-generated if omitted)
location: eastus                          # Azure region (default: eastus)

# Optional: Enablements
enable_ddos_protection: false             # DDoS Protection Plan

# Optional: Tags applied to resources
tags:
  Environment: dev
  Owner: rff-team@company.com
  CreatedBy: terraform
```

## Example Files

### Development Environment

**`dev/rff-react.yaml`**:
```yaml
subscription_name: rff-react-dev
environment: dev
app_code: RFF
module: REACT

owners:
  - 11111111-1111-1111-1111-111111111111
  - 22222222-2222-2222-2222-222222222222

billing_entity: RFF-TEAM
cost_center: CC-RFF-001
application_id: rff-react
location: eastus
```

### Staging Environment

**`staging/rff-react.yaml`**:
```yaml
subscription_name: rff-react-stg
environment: stage
app_code: RFF
module: REACT

owners:
  - 11111111-1111-1111-1111-111111111111
  - 22222222-2222-2222-2222-222222222222

billing_entity: RFF-TEAM
cost_center: CC-RFF-001
application_id: rff-react
location: eastus
```

### Production Environment

**`prod/rff-react.yaml`**:
```yaml
subscription_name: rff-react-prd
environment: prod
app_code: RFF
module: REACT

owners:
  - 11111111-1111-1111-1111-111111111111
  - 22222222-2222-2222-2222-222222222222

billing_entity: RFF-TEAM
cost_center: CC-RFF-001
application_id: rff-react
location: eastus
enable_ddos_protection: true  # Production only
```

## Provisioning Process

1. **Create/Update YAML files** in the appropriate environment directories
2. **Validate YAML** syntax
3. **Run Terraform**:
   ```bash
   cd terraform-azure-subscription-factory
   terraform plan
   terraform apply
   ```
4. **Verify** subscriptions created:
   ```bash
   az account subscription list --query "[?displayName=='rff-react-dev'].{name:displayName, id:subscriptionId}"
   ```

## Key Points

### App Code Mapping
The `app_code` in the YAML must match the management group name:
- `app_code: RFF` → subscription goes under `MG-RFF` management group
- `app_code: ABC` → subscription goes under `MG-ABC` management group
- Management group must be created first in `terraform-azure-landingzone`

### Naming Requirements
- `subscription_name`: Must be unique, lowercase with hyphens
- `app_code`: Must match existing app management group (case-sensitive in lookup)
- `module`: Descriptive name of the workload (REACT, API, ML, etc.)

### Environment Values
Valid environment values (enforced by validation):
- `dev` (Development)
- `stage` (Staging)  
- `prod` (Production)
- `qa` (Quality Assurance)
- `uat` (User Acceptance Testing)
- `sit` (System Integration Testing)

### Getting Principal IDs

For owners field, get AAD object IDs:

```bash
# For a user
az ad user show --id john.doe@company.com --query id

# For a group
az ad group show --group "rff-team" --query id

# List multiple users
az ad user list --query "[].{name:userPrincipalName, id:id}"
```

## Post-Provisioning

After Terraform creates subscriptions:

1. **Verify placement**:
   ```bash
   az account subscription list --query "[?displayName=='rff-react-dev']"
   ```

2. **Check management group**:
   ```bash
   az account management-group subscription show --name mg-rff --subscription rff-react-dev
   ```

3. **Share with app team**:
   - Subscription ID
   - Resource Group name
   - Management Group: MG-RFF
   - Inherited Policies (from Applications and MG-RFF)
   - Owner assignments

4. **Set up app repo**:
   - Create `app-infra` repo
   - Configure Terraform backend to use subscription's state storage
   - Begin deploying application resources

## Troubleshooting

### Management Group Not Found
```
Error: app_code "RFF" management group not found
```
**Solution**: Create MG-RFF first in `terraform-azure-landingzone/management-groups`

### Subscription Name Already Exists
```
Error: subscription name 'rff-react-dev' already exists
```
**Solution**: Choose a unique subscription name

### Principal ID Invalid
```
Error: principal 11111111-1111-1111-1111-111111111111 not found
```
**Solution**: Verify the principal ID exists in your AAD tenant

## Related Documentation

- [APP_MANAGEMENT_GROUP_GUIDE.md](../../APP_MANAGEMENT_GROUP_GUIDE.md) - Complete setup guide
- [ARCHITECTURE_INTEGRATION.md](../../ARCHITECTURE_INTEGRATION.md) - Architecture overview
- [terraform-azure-subscription-factory/README.md](../README.md) - Factory details
