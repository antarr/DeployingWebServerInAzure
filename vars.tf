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

variable "instance_count" {
  description = "Number machines to be created"
  type        = number
  default     = 2
  validation {
    condition     = tobool(var.instance_count < 2 || var.instance_count > 5) == true
    error_message = "The instance_count value must be a number between 2 and 5."
  }
}

variable "packer_resource_group" {
  description = "Resource group for packer image"
  default     = "packer-rg"
}

variable "packer_image_name" {
  description = "Name of image to be used on Virtual Machines"
  default     = "udacityPackerImage"
}
