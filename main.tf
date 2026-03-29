terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  required_version = ">= 1.6.0"
}

provider "azurerm" {
  features {}
  subscription_id = "aba002e6-06b6-422a-ab39-f83257da8724"
}

#lab_rg is just the nickname that TF will use to reference this resource
resource "azurerm_resource_group" "lab_rg"{
name = "la-jc-uk-south-tf"
location = "UK South"
}

# Virtual Network
resource "azurerm_virtual_network" "lab_vnet" {
    name = "lab-jc-vnet-tf"
address_space =["10.0.0.0/16"]
location = azurerm_resource_group.lab_rg.location
resource_group_name =azurerm_resource_group.lab_rg.name
}
#