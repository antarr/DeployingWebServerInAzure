provider "azurerm" {
  tenant_id = "${vars.tenant_id}"
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "udacityDeployResourceGroup"
  location = "East US"
}

resource "azurerm_virtual_network" "main" {
  name                = "udacityDeployVirtualNetwork"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name           = "udacityDeploysubnet"
    address_prefix = "10.0.1.0/24"
  }
}
