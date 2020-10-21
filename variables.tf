variable "location" {
  description = "Region where the virtual network is created"
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group in which the resources will be created"
  default     = "udacity-rg"
}

variable "tags" {
  type        = map(string)
  description = "Tags to be assigned to resources when created"

  default = {
    project = "Deploying WebServer In Azure"
  }
}

variable "prefix" {
  description = "The prefix used for all resources in this example"
  default     = "udacity-deploy"
}

variable "instances" {
  description = "Number machines to be created"
  default     = 1
}
