# Spoke Virtual Network for the application
# This VNet peers with the hub and hosts application resources

resource "azurerm_resource_group" "app_network" {
  count = var.create_spoke_vnet ? 1 : 0

  provider = azurerm.subscription

  name     = "${var.resource_group_name}-network"
  location = var.location

  tags = merge(
    var.tags,
    {
      Purpose = "Application Networking"      Module  = "networking"  # Module-level tag for cost tracking    }
  )
}

# Spoke Virtual Network
resource "azurerm_virtual_network" "spoke" {
  count = var.create_spoke_vnet ? 1 : 0

  provider = azurerm.subscription

  name                = var.spoke_vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.app_network[0].name
  address_space       = var.spoke_vnet_address_space

  tags = merge(
    var.tags,
    {
      Purpose = "Application Workloads"
      TierType = "Spoke"
      Module  = "networking"  # Module-level tag for cost tracking
    }
  )
}

# Application Subnet - for general app workloads
resource "azurerm_subnet" "app" {
  count = var.create_spoke_vnet ? 1 : 0

  provider = azurerm.subscription

  name                 = "snet-app"
  resource_group_name  = azurerm_resource_group.app_network[0].name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = [var.app_subnet_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# AKS Subnet - for Kubernetes clusters
resource "azurerm_subnet" "aks" {
  count = var.create_spoke_vnet && var.enable_aks_subnet ? 1 : 0

  provider = azurerm.subscription

  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.app_network[0].name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = [var.aks_subnet_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Database Subnet - for private endpoints and databases
resource "azurerm_subnet" "database" {
  count = var.create_spoke_vnet && var.enable_database_subnet ? 1 : 0

  provider = azurerm.subscription

  name                 = "snet-database"
  resource_group_name  = azurerm_resource_group.app_network[0].name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = [var.database_subnet_prefix]
  
  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Functions Subnet - for Azure Functions with Premium Plan
resource "azurerm_subnet" "functions" {
  count = var.create_spoke_vnet && var.enable_functions_subnet ? 1 : 0

  provider = azurerm.subscription

  name                 = "snet-functions"
  resource_group_name  = azurerm_resource_group.app_network[0].name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = [var.functions_subnet_prefix]

  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

# Private Endpoints Subnet - for app-specific private endpoints
resource "azurerm_subnet" "private_endpoints" {
  count = var.create_spoke_vnet && var.enable_private_endpoints_subnet ? 1 : 0

  provider = azurerm.subscription

  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.app_network[0].name
  virtual_network_name = azurerm_virtual_network.spoke[0].name
  address_prefixes     = [var.private_endpoints_subnet_prefix]

  private_endpoint_network_policies_enabled             = true
  private_link_service_network_policies_enabled         = false
}

# Network Security Group for Application Subnet
resource "azurerm_network_security_group" "app" {
  count = var.create_spoke_vnet ? 1 : 0

  provider = azurerm.subscription

  name                = "nsg-app-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_network[0].name

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowInternetOutbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with Application Subnet
resource "azurerm_subnet_network_security_group_association" "app" {
  count = var.create_spoke_vnet ? 1 : 0

  provider = azurerm.subscription

  subnet_id                 = azurerm_subnet.app[0].id
  network_security_group_id = azurerm_network_security_group.app[0].id
}

# Network Security Group for Database Subnet
resource "azurerm_network_security_group" "database" {
  count = var.create_spoke_vnet && var.enable_database_subnet ? 1 : 0

  provider = azurerm.subscription

  name                = "nsg-database-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_network[0].name

  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

# Associate NSG with Database Subnet
resource "azurerm_subnet_network_security_group_association" "database" {
  count = var.create_spoke_vnet && var.enable_database_subnet ? 1 : 0

  provider = azurerm.subscription

  subnet_id                 = azurerm_subnet.database[0].id
  network_security_group_id = azurerm_network_security_group.database[0].id
}

# Route Table for Application Subnet - Routes to hub for centralized egress
resource "azurerm_route_table" "app" {
  count = var.create_spoke_vnet && var.hub_vnet_id != null ? 1 : 0

  provider = azurerm.subscription

  name                          = "rt-app-to-hub-${var.environment}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.app_network[0].name
  disable_bgp_route_propagation = false

  route {
    name                   = "RouteToHub"
    address_prefix         = var.hub_vnet_address_space[0]
    next_hop_type          = "VirtualNetworkPeering"
    next_hop_in_ip_address = null
  }

  tags = var.tags
}

# Associate Route Table with Application Subnet
resource "azurerm_subnet_route_table_association" "app" {
  count = var.create_spoke_vnet && var.hub_vnet_id != null ? 1 : 0

  provider = azurerm.subscription

  subnet_id      = azurerm_subnet.app[0].id
  route_table_id = azurerm_route_table.app[0].id
}

# Route Table for Database Subnet
resource "azurerm_route_table" "database" {
  count = var.create_spoke_vnet && var.enable_database_subnet && var.hub_vnet_id != null ? 1 : 0

  provider = azurerm.subscription

  name                          = "rt-database-to-hub-${var.environment}"
  location                      = var.location
  resource_group_name           = azurerm_resource_group.app_network[0].name
  disable_bgp_route_propagation = false

  route {
    name                   = "RouteToHub"
    address_prefix         = var.hub_vnet_address_space[0]
    next_hop_type          = "VirtualNetworkPeering"
    next_hop_in_ip_address = null
  }

  tags = var.tags
}

# Associate Route Table with Database Subnet
resource "azurerm_subnet_route_table_association" "database" {
  count = var.create_spoke_vnet && var.enable_database_subnet && var.hub_vnet_id != null ? 1 : 0

  provider = azurerm.subscription

  subnet_id      = azurerm_subnet.database[0].id
  route_table_id = azurerm_route_table.database[0].id
}

# VNet Peering: Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count = var.create_spoke_vnet && var.hub_vnet_id != null && var.hub_vnet_name != null ? 1 : 0

  provider = azurerm.subscription

  name                      = "peer-${azurerm_virtual_network.spoke[0].name}-to-hub"
  resource_group_name       = azurerm_resource_group.app_network[0].name
  virtual_network_name      = azurerm_virtual_network.spoke[0].name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateway

  depends_on = [azurerm_virtual_network.spoke]
}

# VNet Peering: Hub to Spoke (created in hub context via data source reference)
# This would be created by hub administrator in production

# Private Endpoint for Key Vault (if enabled)
resource "azurerm_private_endpoint" "keyvault" {
  count = var.create_spoke_vnet && var.enable_private_endpoints_subnet && var.keyvault_id != null ? 1 : 0

  provider = azurerm.subscription

  name                = "pep-keyvault-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_network[0].name
  subnet_id           = azurerm_subnet.private_endpoints[0].id

  private_service_connection {
    name                           = "psc-keyvault"
    is_manual_connection           = false
    private_connection_resource_id = var.keyvault_id
    subresource_names              = ["vault"]
  }

  tags = var.tags
}

# Private Endpoint for Storage Account (if enabled)
resource "azurerm_private_endpoint" "storage" {
  count = var.create_spoke_vnet && var.enable_private_endpoints_subnet && var.storage_account_id != null ? 1 : 0

  provider = azurerm.subscription

  name                = "pep-storage-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_network[0].name
  subnet_id           = azurerm_subnet.private_endpoints[0].id

  private_service_connection {
    name                           = "psc-storage"
    is_manual_connection           = false
    private_connection_resource_id = var.storage_account_id
    subresource_names              = ["blob"]
  }

  tags = var.tags
}

# Private Endpoint for SQL Database (if enabled)
resource "azurerm_private_endpoint" "sqldb" {
  count = var.create_spoke_vnet && var.enable_private_endpoints_subnet && var.sqldb_id != null ? 1 : 0

  provider = azurerm.subscription

  name                = "pep-sqldb-${var.environment}"
  location            = var.location
  resource_group_name = azurerm_resource_group.app_network[0].name
  subnet_id           = azurerm_subnet.private_endpoints[0].id

  private_service_connection {
    name                           = "psc-sqldb"
    is_manual_connection           = false
    private_connection_resource_id = var.sqldb_id
    subresource_names              = ["sqlServer"]
  }

  tags = var.tags
}

# Log Analytics Workspace Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "spoke_vnet" {
  count = var.create_spoke_vnet ? 1 : 0

  provider = azurerm.subscription

  name                       = "diag-vnet-spoke"
  target_resource_id         = azurerm_virtual_network.spoke[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.baseline.id

  enabled_log {
    category = "VMProtectionAlerts"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
