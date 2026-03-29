terraform {
  required_providers {
    aci = {
      # The official Cisco ACI provider on the Terraform registry.
      source = "CiscoDevNet/aci"


      version = "~> 2.13"
    }
  }
}

provider "aci" {
  # variables defined in variables.tf but avtually come from terraform.tfvars
  url      = var.apic_url
  username = var.apic_username
  password = var.apic_password

  # dont validate teh self siged cert in aci sim
  insecure = true
}
