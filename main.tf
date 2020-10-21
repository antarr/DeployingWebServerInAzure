provider "azurerm" {
  version = "~>2.0"
  features {}
}

locals {
  instance_count = var.instances
}

resource "azurerm_resource_group" "udacity_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "udacity_vn" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.udacity_rg.location
  resource_group_name = azurerm_resource_group.udacity_rg.name
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "udacity_sn" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.udacity_rg.name
  virtual_network_name = azurerm_virtual_network.udacity_vn.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "udacity_pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.udacity_rg.name
  location            = azurerm_resource_group.udacity_rg.location
  allocation_method   = "Dynamic"

  tags = var.tags
}

resource "azurerm_network_interface" "udacity_ni" {
  count               = local.instance_count
  name                = "${var.prefix}-nic${count.index}"
  resource_group_name = azurerm_resource_group.udacity_rg.name
  location            = azurerm_resource_group.udacity_rg.location

  ip_configuration {
    name                          = "primary"
    # subnet_id                     = azurerm_subnet.udacity_sn.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "udacity_nsg" {
  name                = "${var.prefix}-security-group"
  location            = azurerm_resource_group.udacity_rg.location
  resource_group_name = azurerm_resource_group.udacity_rg.name
  tags                = var.tags

  security_rule {
    name                       = "https"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
