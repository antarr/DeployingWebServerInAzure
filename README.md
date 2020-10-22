# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

For this project, you will write a Packer template and a Terraform template to deploy a customizable, scalable web server in Azure.

### Getting Started

1. Clone this repository
2. Ensure you have all dependencies listed below
3. Export environment variables required by packer. Can be found in the azure portal
   1. ARM_CLIENT_ID - from Terraform app registration that can be found or create in Azure Portal
   2. ARM_CLIENT_SECRET - create in azure portal under app registrations
   3. ARM_SUBSCRIPTION_ID - your Azure subscriptions
4. Follow the instructions below in order

### Dependencies

1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

- Create Tagging Security Policy using template using the command below
  - `az policy definition create --name tagging-policy --mode indexed --rules taggingpolicy.json`

- Apply tagging sercurity policy in Azure Portal
  - [follow guide managing policies](https://docs.microsoft.com/en-us/azure/governance/policy/tutorials/create-and-manage#assign-a-policy)

- Ensure resource group `packer-rg` exists in zone of your choice using the command below***
  - `az group create -l eastus -n packer-rg`

- Deploy the server image
  - `ARM_CLIENT_ID=your_client_id ARM_CLIENT_SECRET=your_client_secret ARM_SUBSCRIPTION_ID=your_subscription_id packer build server.json`

- Deploy resources to Azure using `main.tf`
  1. create plan
    - `terraform plan -out solution.plan`
  2. apply plan
    - `terraform apply "solution.plan"`

### Notes

- Configuring using variables

    The file `vars.tf` contains definitions for variables used by Terrafrom.
    This file provides descriptions of the purpose of each variable as well default values.
    The values of variables can be modified in the command line when calling `terraform apply` or `terraform plan`, i.e. `terraform plan -var 'location=westus'`

# Output

A network of virtual machines will be created behind a loadbalancer which are accessed through a single public IP address
You can run `terraform show` and should get a response similar to below.

```
# azurerm_availability_set.udacity_aset:
resource "azurerm_availability_set" "udacity_aset" {
    id                           = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/availabilitySets/udacity-aset"
    location                     = "eastus"
    managed                      = true
    name                         = "udacity-aset"
    platform_fault_domain_count  = 3
    platform_update_domain_count = 5
    resource_group_name          = "udacity-rg"
    tags                         = {
        "project" = "Deploying WebServer In Azure"
    }
}

# azurerm_lb.udacity_lb:
resource "azurerm_lb" "udacity_lb" {
    id                   = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/loadBalancers/udacity-deploy-loadbalancer"
    location             = "eastus"
    name                 = "udacity-deploy-loadbalancer"
    private_ip_addresses = []
    resource_group_name  = "udacity-rg"
    sku                  = "Basic"

    frontend_ip_configuration {
        id                            = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/loadBalancers/udacity-deploy-loadbalancer/frontendIPConfigurations/PublicIPAddress"
        inbound_nat_rules             = []
        load_balancer_rules           = []
        name                          = "PublicIPAddress"
        outbound_rules                = []
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        public_ip_address_id          = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/publicIPAddresses/udacity-deploy-pip"
    }
}

# azurerm_lb_backend_address_pool.udacity_lb_bap:
resource "azurerm_lb_backend_address_pool" "udacity_lb_bap" {
    backend_ip_configurations = []
    id                        = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/loadBalancers/udacity-deploy-loadbalancer/backendAddressPools/UdacityBackEndAddressPool"
    load_balancing_rules      = []
    loadbalancer_id           = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/loadBalancers/udacity-deploy-loadbalancer"
    name                      = "UdacityBackEndAddressPool"
    resource_group_name       = "udacity-rg"
}

# azurerm_linux_virtual_machine.udacity_vms[0]:
resource "azurerm_linux_virtual_machine" "udacity_vms" {
    admin_username                  = "udacity_admin"
    allow_extension_operations      = true
    availability_set_id             = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/availabilitySets/UDACITY-ASET"
    computer_name                   = "udacity-deploy-machines-0"
    disable_password_authentication = true
    encryption_at_host_enabled      = false
    id                              = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/virtualMachines/udacity-deploy-machines-0"
    location                        = "eastus"
    max_bid_price                   = -1
    name                            = "udacity-deploy-machines-0"
    network_interface_ids           = [
        "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/networkInterfaces/udacity-deploy-ni-0",
    ]
    priority                        = "Regular"
    private_ip_address              = "10.0.2.4"
    private_ip_addresses            = [
        "10.0.2.4",
    ]
    provision_vm_agent              = true
    public_ip_addresses             = []
    resource_group_name             = "udacity-rg"
    size                            = "Standard_F2"
    source_image_id                 = "/subscriptions/your-subscription/resourceGroups/packer-rg/providers/Microsoft.Compute/images/udacityPackerImage"
    virtual_machine_id              = "23795a8e-8fe6-4b54-a9c9-08da3e4b4158"

    admin_ssh_key {
        public_key = <<~EOT
            your ssh key
        EOT
        username   = "udacity_admin"
    }

    os_disk {
        caching                   = "ReadWrite"
        disk_size_gb              = 30
        name                      = "udacity-deploy-machines-0_disk1_0e8fa63e454d4b8d9de0f920574bf944"
        storage_account_type      = "Standard_LRS"
        write_accelerator_enabled = false
    }
}

# azurerm_managed_disk.udacity_md[0]:
resource "azurerm_managed_disk" "udacity_md" {
    create_option        = "Empty"
    disk_iops_read_write = 500
    disk_mbps_read_write = 60
    disk_size_gb         = 1
    id                   = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/disks/udacticy_md_0"
    location             = "eastus"
    name                 = "udacticy_md_0"
    resource_group_name  = "udacity-rg"
    storage_account_type = "Standard_LRS"
    tags                 = {
        "project" = "Deploying WebServer In Azure"
    }
}

# azurerm_network_interface.udacity_ni[0]:
resource "azurerm_network_interface" "udacity_ni" {
    applied_dns_servers           = []
    dns_servers                   = []
    enable_accelerated_networking = false
    enable_ip_forwarding          = false
    id                            = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/networkInterfaces/udacity-deploy-ni-0"
    internal_domain_name_suffix   = "tmxm1ci3mseejoxt3yjbcupnvd.bx.internal.cloudapp.net"
    location                      = "eastus"
    name                          = "udacity-deploy-ni-0"
    private_ip_address            = "10.0.2.4"
    private_ip_addresses          = [
        "10.0.2.4",
    ]
    resource_group_name           = "udacity-rg"
    tags                          = {
        "project" = "Deploying WebServer In Azure"
    }

    ip_configuration {
        name                          = "udacity_nic_config-0"
        primary                       = true
        private_ip_address            = "10.0.2.4"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_version    = "IPv4"
        subnet_id                     = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/virtualNetworks/udacity-deploy-network/subnets/internal"
    }
}

# azurerm_network_interface_backend_address_pool_association.udacity_ni_bapa[0]:
resource "azurerm_network_interface_backend_address_pool_association" "udacity_ni_bapa" {
    backend_address_pool_id = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/loadBalancers/udacity-deploy-loadbalancer/backendAddressPools/UdacityBackEndAddressPool"
    id                      = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/networkInterfaces/udacity-deploy-ni-0/ipConfigurations/udacity_nic_config-0|/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/loadBalancers/udacity-deploy-loadbalancer/backendAddressPools/UdacityBackEndAddressPool"
    ip_configuration_name   = "udacity_nic_config-0"
    network_interface_id    = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/networkInterfaces/udacity-deploy-ni-0"
}

# azurerm_network_security_group.udacity_nsg:
resource "azurerm_network_security_group" "udacity_nsg" {
    id                  = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/networkSecurityGroups/udacity-deploy-security-group"
    location            = "eastus"
    name                = "udacity-deploy-security-group"
    resource_group_name = "udacity-rg"
    security_rule       = [
        {
            access                                     = "Allow"
            description                                = ""
            destination_address_prefix                 = "*"
            destination_address_prefixes               = []
            destination_application_security_group_ids = []
            destination_port_range                     = "443"
            destination_port_ranges                    = []
            direction                                  = "Inbound"
            name                                       = "https"
            priority                                   = 101
            protocol                                   = "*"
            source_address_prefix                      = "*"
            source_address_prefixes                    = []
            source_application_security_group_ids      = []
            source_port_range                          = "*"
            source_port_ranges                         = []
        },
    ]
    tags                = {
        "project" = "Deploying WebServer In Azure"
    }
}

# azurerm_public_ip.udacity_pip:
resource "azurerm_public_ip" "udacity_pip" {
    allocation_method       = "Dynamic"
    id                      = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/publicIPAddresses/udacity-deploy-pip"
    idle_timeout_in_minutes = 4
    ip_version              = "IPv4"
    location                = "eastus"
    name                    = "udacity-deploy-pip"
    resource_group_name     = "udacity-rg"
    sku                     = "Basic"
    tags                    = {
        "project" = "Deploying WebServer In Azure"
    }
}

# azurerm_resource_group.udacity_rg:
resource "azurerm_resource_group" "udacity_rg" {
    id       = "/subscriptions/your-subscription/resourceGroups/udacity-rg"
    location = "eastus"
    name     = "udacity-rg"
}

# azurerm_subnet.udacity_sn:
resource "azurerm_subnet" "udacity_sn" {
    address_prefix                                 = "10.0.2.0/24"
    address_prefixes                               = [
        "10.0.2.0/24",
    ]
    enforce_private_link_endpoint_network_policies = false
    enforce_private_link_service_network_policies  = false
    id                                             = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/virtualNetworks/udacity-deploy-network/subnets/internal"
    name                                           = "internal"
    resource_group_name                            = "udacity-rg"
    virtual_network_name                           = "udacity-deploy-network"
}

# azurerm_virtual_machine_data_disk_attachment.udacity_mda[0]:
resource "azurerm_virtual_machine_data_disk_attachment" "udacity_mda" {
    caching                   = "ReadWrite"
    create_option             = "Attach"
    id                        = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/virtualMachines/udacity-deploy-machines-0/dataDisks/udacticy_md_0"
    lun                       = 10
    managed_disk_id           = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/disks/udacticy_md_0"
    virtual_machine_id        = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Compute/virtualMachines/udacity-deploy-machines-0"
    write_accelerator_enabled = false
}

# azurerm_virtual_network.udacity_vn:
resource "azurerm_virtual_network" "udacity_vn" {
    address_space       = [
        "10.0.0.0/16",
    ]
    guid                = "somevalue"
    id                  = "/subscriptions/your-subscription/resourceGroups/udacity-rg/providers/Microsoft.Network/virtualNetworks/udacity-deploy-network"
    location            = "eastus"
    name                = "udacity-deploy-network"
    resource_group_name = "udacity-rg"
    subnet              = []
    tags                = {
        "project" = "Deploying WebServer In Azure"
    }
}

# data.azurerm_image.packer_image:
data "azurerm_image" "packer_image" {
    data_disk           = []
    id                  = "/subscriptions/your-subscription/resourceGroups/packer-rg/providers/Microsoft.Compute/images/udacityPackerImage"
    location            = "eastus"
    name                = "udacityPackerImage"
    os_disk             = [
        {
            blob_uri        = ""
            caching         = "ReadWrite"
            managed_disk_id = "/subscriptions/your-subscription/resourceGroups/PKR-RESOURCE-GROUP-VRPAKWHS1G/providers/Microsoft.Compute/disks/pkrosvrpakwhs1g"
            os_state        = "Generalized"
            os_type         = "Linux"
            size_gb         = 30
        },
    ]
    resource_group_name = "packer-rg"
    sort_descending     = false
    tags                = {
        "Udacity" = "test"
    }
    zone_resilient      = false
}

# data.azurerm_resource_group.packer_rg:
data "azurerm_resource_group" "packer_rg" {
    id       = "/subscriptions/your-subscription/resourceGroups/packer-rg"
    location = "eastus"
    name     = "packer-rg"
    tags     = {}
}
```
