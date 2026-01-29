# Terraform Azure Subscription Factory

Automatically provision Azure subscriptions with complete infrastructure for application teams.

## Overview

This factory enables self-service subscription provisioning with:

- ✅ **App-level Management Group** created automatically (e.g., MG-APP1, MG-RFF)
- ✅ **Subscription** in correct management group hierarchy
- ✅ **Spoke VNet** with multiple subnets for different workload types
- ✅ **Network Security Groups** for application and database isolation
- ✅ **Route Tables** for hub-spoke routing
- ✅ **Subnet Delegations** for App Services, AKS, Functions, Databases
- ✅ **Private Endpoints** for Key Vault, Storage, SQL Database
- ✅ **VNet Peering** to hub for centralized egress/security
- ✅ **Azure Policies** applied at subscription level
- ✅ **RBAC** configured for team access
- ✅ **Budget & Cost Management** with alerts
- ✅ **Log Analytics** workspace for monitoring

## Flow Diagram

```
App Team Onboarding Request (rff-react example)
        ↓
Subscription Factory (Terraform)
        ↓
┌──────────────────────────────────────────┐
├─ App Management Group: MG-RFF            ├
│  ├─ Subscription: sub-rff-react-prod    │
│  │  ├─ Resource Group (Baseline)        │
│  │  ├─ Log Analytics Workspace          │
│  │  └─ Spoke VNet: vnet-rff-spoke-prod  │
│  │     ├─ App Subnet (snet-app)        │
│  │     ├─ AKS Subnet (snet-aks)        │
│  │     ├─ Database Subnet              │
│  │     ├─ Functions Subnet             │
│  │     ├─ Private Endpoints Subnet     │
│  │     ├─ NSGs (App, Database)         │
│  │     ├─ Route Tables (to hub)        │
│  │     └─ Peering to Hub VNet          │
│  ├─ Private Endpoints                  │
│  │  ├─ Key Vault (kv-rff-prod)         │
│  │  ├─ Storage Account                 │
│  │  └─ SQL Database                    │
│  ├─ Policies Applied                   │
│  │  ├─ VM SKU restrictions             │
│  │  ├─ Naming conventions              │
│  │  └─ Regional restrictions           │
│  └─ RBAC Configured                    │
│     ├─ App owners (Owner role)         │
│     ├─ App contributors (Contributor)  │
│     └─ FinOps readers (Reader)         │
└──────────────────────────────────────────┘
        ↓
Ready for App Team Deployment
```

## Quick Start: Onboarding an App (rff-react example)

### 1. Create Request File

Create a `.tfvars` file in `requests/prod/`:

```hcl
# requests/prod/rff-react.tfvars

app_code        = "rff"  # Three-letter code
module          = "react"
environment     = "prod"
location        = "eastus"
billing_entity  = "marketing"

# Team Configuration
owners = [
  "00000000-0000-0000-0000-000000000001",  # App owner object ID
]

app_contributor_groups = [
  "rff-team-contributors",
]

# Network Configuration (Spoke VNet + Subnets + Private Endpoints)
create_spoke_vnet               = true
spoke_vnet_address_space        = ["10.100.0.0/16"]

# Enable workload-specific subnets
enable_aks_subnet               = true      # For containerized workloads
enable_database_subnet          = true      # For managed databases
enable_functions_subnet         = true      # For serverless functions
enable_private_endpoints_subnet = true      # For app-specific private endpoints

# Hub VNet Peering (connect to centralized hub for egress/security)
hub_vnet_id            = "/subscriptions/xxxxx/resourceGroups/.../virtualNetworks/vnet-hub-prod"
hub_vnet_name          = "vnet-hub-prod"
hub_vnet_address_space = ["10.0.0.0/16"]

# Private Endpoints for Shared Services
keyvault_id      = "/subscriptions/xxxxx/resourceGroups/.../vaults/kv-rff-prod"
storage_account_id = "/subscriptions/xxxxx/resourceGroups/.../storageAccounts/sta..."
sqldb_id         = "/subscriptions/xxxxx/resourceGroups/.../databases/..."

# Cost Management
monthly_budget         = 5000  # $5,000/month
budget_alert_threshold = 80    # Alert at 80%

# Security
enable_defender = true
```

### 2. Deploy via Terraform

```bash
cd terraform-azure-subscription-factory

# Plan for specific environment
terraform plan \
  -var-file="environments/prod/terraform.tfvars" \
  -var-file="requests/prod/rff-react.tfvars"

# Apply
terraform apply \
  -var-file="environments/prod/terraform.tfvars" \
  -var-file="requests/prod/rff-react.tfvars"
```

### 3. Verify Deployment

```bash
# Get subscription and VNet details
terraform output subscription_id
terraform output spoke_vnet_id
terraform output spoke_vnet_name

# View app management group
az account management-group show --name "mg-rff"

# Check VNet peering status
az network vnet peering list --resource-group "rg-rff-network-prod" --vnet-name "vnet-rff-spoke-prod"
```

## Architecture: What Gets Created

When you onboard an app like `rff-react`, here's exactly what's provisioned:

### Management Groups
```
Applications (Parent from Landing Zone)
└── MG-RFF (App-level MG - created automatically)
    └── Subscription: sub-rff-react-prod
```

### Subscription Infrastructure
```
Subscription: sub-rff-react-prod
├── Management Groups: Correct hierarchy established
├── Baseline Resources
│   ├── Resource Group: rg-rff-baseline-prod
│   ├── Log Analytics: law-rff-baseline-prod (30-day retention)
│   └── DDoS Protection Plan (optional)
└── Networking
    ├── Spoke VNet: vnet-rff-spoke-prod (10.100.0.0/16)
    │   ├── Subnets:
    │   │   ├── snet-app (10.100.1.0/24) - App Services, Web Apps
    │   │   ├── snet-aks (10.100.2.0/24) - AKS Clusters
    │   │   ├── snet-database (10.100.3.0/24) - Databases, Private Endpoints
    │   │   ├── snet-functions (10.100.4.0/24) - Azure Functions (Premium)
    │   │   └── snet-private-endpoints (10.100.5.0/24) - App-specific PEPs
    │   ├── Network Security Groups:
    │   │   ├── nsg-app-prod
    │   │   │   ├── Allow VNet-to-VNet traffic
    │   │   │   └── Allow Outbound Internet
    │   │   └── nsg-database-prod
    │   │       └── Allow VNet-to-VNet traffic only
    │   ├── Route Tables:
    │   │   ├── rt-app-to-hub-prod (routes to hub via peering)
    │   │   └── rt-database-to-hub-prod (routes to hub via peering)
    │   └── VNet Peering:
    │       └── peer-vnet-rff-spoke-prod-to-hub (bidirectional with hub)
    │
    └── Private Endpoints (for shared services):
        ├── pep-keyvault-prod → kv-rff-prod
        ├── pep-storage-prod → Storage Account blob
        └── pep-sqldb-prod → SQL Database
```

### Policies Applied
```
Policy Assignments (from terraform-policy-as-code):
├── VM SKU Restrictions
│   └── Only approved SKUs allowed (D4s, D8s, B4ms)
├── Naming Conventions
│   └── Enforced pattern: ^[a-z]+-[a-z]+-[a-z]+(-[a-z0-9]+)?$
└── Regional Restrictions
    └── Only eastus, westus2 allowed
```

### RBAC Configuration
```
Subscription-Level Roles:
├── App Owners: Owner role (from owners list)
├── App Contributors: Contributor role (from groups)
└── FinOps Readers: Reader role (for cost analysis)

App Management Group Roles:
├── App Owners: Management Group Contributor
└── App Contributors: Contributor
```

## Subnet Delegation Details

Each subnet is configured for specific workload types:

| Subnet | Type | Delegation | Use Case |
|--------|------|-----------|----------|
| snet-app | Application | Microsoft.Web/serverFarms | App Service, Web Apps |
| snet-aks | Compute | Microsoft.ContainerService | AKS Clusters |
| snet-database | Data | Microsoft.DBforPostgreSQL | Managed Databases |
| snet-functions | Serverless | Microsoft.Web/serverFarms | Azure Functions (Premium) |
| snet-private-endpoints | Network | None | Private Endpoints |

## Private Endpoints for App Resources

The factory creates private endpoints for:
- **Key Vault** - Secure secrets access
- **Storage Account** (Blob) - App data storage
- **SQL Database** - Relational data

These prevent data exfiltration and ensure traffic stays within the VNet.

## Networking Diagram

```
App Team Request: rff-react
                ↓
        ┌───────────────┐
        │ spoke VNet    │
        │ 10.100.0.0/16 │
        │               │
        │ ┌─────────────┤
        │ │ snet-app    │─ App Service, Web Apps
        │ ├─────────────┤
        │ │ snet-aks    │─ AKS, Microservices
        │ ├─────────────┤
        │ │ snet-db     │─ SQL, PostgreSQL (via PE)
        │ ├─────────────┤
        │ │ snet-func   │─ Azure Functions
        │ └─────────────┤
        └───────┬───────┘
                │ VNet Peering
                │ (bidirectional)
                ↓
        ┌───────────────┐
        │ hub VNet      │
        │ 10.0.0.0/16   │
        │               │
        │ Gateway ──────── VPN/ExpressRoute
        │ Bastion ──────── Admin access
        │ Firewall ─────── Central egress
        │ NAT ──────────── Outbound traffic
        └───────────────┘
```

## Variable Configuration Guide

### Networking Variables

```hcl
# VNet Creation
create_spoke_vnet = true/false                    # Enable/disable spoke VNet
spoke_vnet_address_space = ["10.100.0.0/16"]     # CIDR block for spoke

# Subnet Prefix Allocation
app_subnet_prefix                = "10.100.1.0/24"
enable_aks_subnet                = true/false
aks_subnet_prefix                = "10.100.2.0/24"
enable_database_subnet           = true/false
database_subnet_prefix           = "10.100.3.0/24"
enable_functions_subnet          = true/false
functions_subnet_prefix          = "10.100.4.0/24"
enable_private_endpoints_subnet  = true/false
private_endpoints_subnet_prefix  = "10.100.5.0/24"

# Hub VNet Configuration
hub_vnet_id            = "Resource ID of hub VNet"
hub_vnet_name          = "Name of hub VNet"
hub_vnet_address_space = ["10.0.0.0/16"]
use_remote_gateway     = true/false  # Use hub's VPN gateway

# Private Endpoints
keyvault_id       = "Resource ID of Key Vault"
storage_account_id = "Resource ID of Storage"
sqldb_id          = "Resource ID of SQL DB"
```

## Module Structure

```
modules/subscription/
├── main.tf              # App MG, Subscription, baseline resources
├── networking.tf        # Spoke VNet, subnets, NSGs, route tables, peering, PEPs
├── policies.tf          # Policy assignments
├── roles.tf             # RBAC configuration
├── budget.tf            # Cost management alerts
├── defender.tf          # Microsoft Defender setup
├── variables.tf         # All variable definitions
├── outputs.tf           # Outputs for referencing resources
└── versions.tf          # Provider versions
```

## Outputs Available

After deployment, access these outputs:

```bash
# Subscription Info
terraform output subscription_id
terraform output subscription_name

# Networking
terraform output spoke_vnet_id
terraform output spoke_vnet_name
terraform output app_subnet_id
terraform output aks_subnet_id
terraform output database_subnet_id
terraform output functions_subnet_id
terraform output private_endpoints_subnet_id

# Security
terraform output app_nsg_id
terraform output database_nsg_id
terraform output app_route_table_id

# Private Endpoints
terraform output keyvault_private_endpoint_id
terraform output storage_private_endpoint_id
terraform output sqldb_private_endpoint_id

# Peering
terraform output vnet_peering_id

# Monitoring
terraform output log_analytics_workspace_id
```

## Requirements

- Terraform >= 1.5.0
- Azure Provider ~> 3.80.0
- Hub VNet already exists (for peering)
- Hub VNet ID available as variable

## Cost Considerations

- **Spoke VNet**: ~$0.10/month
- **VNet Peering**: ~$0.02 per GB transferred
- **Private Endpoints**: ~$0.50/month each (3 = $1.50/month)
- **NSGs**: ~$2-4/month depending on rules
- **Route Tables**: ~$3-5/month
- **Log Analytics**: Included in baseline resources

**Estimated monthly cost per spoke**: $5-10 (excluding compute/storage)

## Example: Full Onboarding Request

See [requests/prod/rff-react.tfvars.example](requests/prod/rff-react.tfvars.example) for a complete working example.

## Security Best Practices

✅ **NSGs**: Application and database subnets isolated
✅ **Private Endpoints**: No internet exposure for data access
✅ **VNet Peering**: Route traffic through hub for monitoring
✅ **Policies**: Enforced naming, SKUs, regions
✅ **RBAC**: Least privilege access per team role

## Troubleshooting

### VNet Peering Failed
- Verify `hub_vnet_id` is correct and exists
- Check subscription context is correct
- Ensure hub VNet is in correct subscription

### Private Endpoint Creation Failed
- Verify Key Vault, Storage, SQL DB IDs are correct
- Ensure resources exist and are accessible
- Check subnet has `private_endpoint_network_policies_enabled = true`

### Subnet Delegation Failed
- Check service principal has `Microsoft.Network/virtualNetworks/subnets/action`
- Verify delegation service name is correct

## Related Documentation

- [APP Spoke Integration](../docs/APP_SPOKE_INTEGRATION.md)
- [Onboarding Guide](../docs/ONBOARDING.md)
- [Architecture Integration](../ARCHITECTURE_INTEGRATION.md)
