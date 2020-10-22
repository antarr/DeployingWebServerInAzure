provider "azurerm" {
  version = "~>2.0"
  features {}
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

resource "azurerm_network_interface" "udacity_ni" {
  name                = "${var.prefix}-ni"
  resource_group_name = azurerm_resource_group.udacity_rg.name
  location            = azurerm_resource_group.udacity_rg.location

  ip_configuration {
    name                          = "primary"
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_public_ip" "udacity_pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.udacity_rg.name
  location            = azurerm_resource_group.udacity_rg.location
  allocation_method   = "Dynamic"

  tags = var.tags
}

resource "azurerm_lb" "udacity_lb" {
  name                = "${var.prefix}-loadbalancer"
  resource_group_name = azurerm_resource_group.udacity_rg.name
  location            = azurerm_resource_group.udacity_rg.location

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.udacity_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "udacity_lb_bap" {
  resource_group_name = azurerm_resource_group.udacity_rg.name
  loadbalancer_id     = azurerm_lb.udacity_lb.id
  name                = "UdacityBackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "udacity_ni_bapa" {
  network_interface_id    = azurerm_network_interface.udacity_ni.id
  ip_configuration_name   = "udacityConfiguration"
  backend_address_pool_id = azurerm_lb_backend_address_pool.udacity_lb_bap.id
}

resource "azurerm_availability_set" "udacity_aset" {
  name                = "udacity-aset"
  location            = azurerm_resource_group.udacity_rg.location
  resource_group_name = azurerm_resource_group.udacity_rg.name

  tags = var.tags
}

data "azurerm_resource_group" "packer_rg" {
  name = var.packer_resource_group
}

resource "azurerm_image" "packer_image" {
  name                = var.packer_image_name
  location            = azurerm_resource_group.udacity_rg.location
  resource_group_name = data.azurerm_resource_group.packer_rg.name
}

resource "azurerm_linux_virtual_machine_scale_set" "udacity_vms" {
  name                = "${var.prefix}-machines"
  instances           = var.instance_count
  resource_group_name = azurerm_resource_group.udacity_rg.name
  location            = azurerm_resource_group.udacity_rg.location
  sku                 = "Standard_F2"
  admin_username      = "udacity_admin"
  source_image_id     = azurerm_image.packer_image.id
  network_interface {
    name    = "primary_ni"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = azurerm_subnet.udacity_sn.id
    }
  }

  admin_ssh_key {
    username   = "udacity_admin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
