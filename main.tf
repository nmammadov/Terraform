provider "azurerm" {
  subscription_id    = var.subscription_id
  client_id          = var.client_id
  client_secret      = var.client_secret
  tenant_id          = var.tenant_id
  features {}
}
terraform {
  backend "remote" {
    organization = "nizami"

    workspaces {
      name = "Terraform"
    }
  }
}

resource "azurerm_resource_group" "rg1" {
  name     = var.rg1
  location = var.rg1_location
}

resource "azurerm_resource_group" "rg2" {
  name     = "TF-RG-2"
  location = var.rg1_location
}


resource "azurerm_virtual_network" "vnet1" {
  for_each = var.vnets
  name                = each.key
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = [each.value]
 
  subnet {
    name           = "subnet1"
    address_prefix = cidrsubnet(each.value,8,1)
  }

  subnet {
    name           = "subnet2"
    address_prefix = cidrsubnet(each.value,8,2)
  }

}

resource "azurerm_subnet" "gw-sub" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1["HUB"].name
  address_prefixes     = [var.gw_subnet]
}

resource "azurerm_local_network_gateway" "home" {
  name                = var.localgw_name
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  gateway_address     = var.public_ip
  address_space       = [var.vpn_network[0]]
}

resource "azurerm_public_ip" "ip1" {
  name                = "vpn-public-ip"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  allocation_method = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "vg1" {
  name                = "VG1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.ip1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-sub.id
  }
}

resource "azurerm_virtual_network_gateway_connection" "vpn1" {
  name                = "IPSec1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vg1.id
  local_network_gateway_id   = azurerm_local_network_gateway.home.id

  shared_key = var.psk
}


