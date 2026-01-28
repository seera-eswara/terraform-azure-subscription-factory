# Subscription Request Template

## Instructions for App Teams

To request a new Azure subscription, follow these steps:

1. **Create a YAML file** in `requests/<environment>/` with your subscription details
2. **Commit and push** to a feature branch
3. **Create a Pull Request** - the workflow will validate and provision
4. **Merge to main** - Terraform will automatically create the subscription

## YAML Format

```yaml
# requests/dev/my-app.yaml
subscription_name: my-app-dev          # Team name + environment (lowercase, hyphens)
environment: dev                       # One of: dev, stage, prod, qa, uat, sit
app_code: app                          # 3-letter app code; maps to MG: lz-<app_code>
owners:                                # Azure AD object IDs of subscription admins
  - "11111111-1111-1111-1111-111111111111"
  - "22222222-2222-2222-2222-222222222222"

# Optional fields
monthly_budget: 5000                   # Monthly spend limit (USD, 0 = disabled)
budget_alert_threshold: 80             # Alert % (default: 80)
alert_emails:                          # Email recipients for budget alerts
  - "team-lead@company.com"
  - "finance@company.com"
billing_entity: "CC-1234"              # Cost center for chargeback
enable_defender: true                  # Enable Microsoft Defender (default: true)
enable_ddos_protection: true           # Enable DDoS protection (default: true)
```

## Naming Convention

Subscriptions follow this naming pattern:

```
<app-code>-<environment>-<region>-<instance>

Examples:
  crm-dev-eus-01        # Customer Relationship Management, Dev, East US
  erp-prod-weu-01       # Enterprise Resource Planning, Prod, West Europe
  app-stage-eus-02      # Generic App, Stage, East US
```

Each subscription automatically gets:
- ✅ Baseline resource group
- ✅ Log Analytics workspace
- ✅ DDoS protection plan
- ✅ Microsoft Defender enabled
- ✅ Budget alerts configured
- ✅ Standardized tags

## Example Requests

### Development Subscription

```yaml
subscription_name: analytics-dev
environment: dev
app_code: anl
owners:
  - 11111111-1111-1111-1111-111111111111
monthly_budget: 2000
alert_emails:
  - analytics-team@company.com
```

### Production Subscription

```yaml
subscription_name: payment-processor-prod
environment: prod
app_code: pay
owners:
  - 22222222-2222-2222-2222-222222222222
  - 33333333-3333-3333-3333-333333333333
monthly_budget: 50000
budget_alert_threshold: 70
alert_emails:
  - cloud-team@company.com
  - finance@company.com
enable_defender: true
enable_ddos_protection: true
```

## cloud Teams - Governance

### Registered App Codes

| Code | Team | Owner | Contact |
|------|------|-------|---------|
| crm | Sales cloud | John Doe | john@company.com |
| erp | Finance Systems | Jane Smith | jane@company.com |
| app | App Team 1 | Bob Johnson | bob@company.com |

### Regional Preferences

Teams should use these regions:
- **North America**: `eus` (East US), `cus` (Central US)
- **Europe**: `weu` (West Europe), `neu` (North Europe)
- **Asia Pacific**: `sea` (Southeast Asia), `aue` (Australia East)

### Budget Guidelines

| Environment | Max Monthly | Alert % | Exceptions |
|-----------|-----------|---------|-----------|
| dev | 5,000 | 80 | Finance approval required |
| qa | 10,000 | 75 | Finance approval required |
| stage | 20,000 | 70 | VP approval required |
| prod | 100,000+ | 60 | Executive approval required |

## Workflow Process

```
1. Team submits YAML request (PR)
           ↓
2. GitHub Actions validates format
           ↓
   ✓ Valid → Approve/Merge
   ✗ Invalid → Request changes
           ↓
3. Merge to main triggers provisioning
           ↓
4. Terraform creates:
   - New subscription
   - Place in correct management group
   - Create baseline RG + Log Analytics
   - Enable Defender + DDoS
   - Configure budgets
   - Assign RBAC
           ↓
5. Team notified with subscription ID
```

## Troubleshooting

**Problem**: "Invalid environment"
**Solution**: Use one of: dev, stage, prod, qa, uat

**Problem**: "Missing subscription_name"
**Solution**: Add `subscription_name: <value>` to YAML

**Problem**: "Invalid budget threshold"
**Solution**: Budget alert threshold must be 0-100

**Problem**: Provisioning timeout
**Solution**: Check your budget values and billing scope configuration

## Support

For help with subscription requests:
- 📧 cloud-engineering@company.com
- 💬 #cloud-engineering Slack channel
- 📋 Internal wiki: https://wiki.company.com/azure
