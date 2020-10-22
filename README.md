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

**Your words here**
