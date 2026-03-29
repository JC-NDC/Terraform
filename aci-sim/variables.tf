# variables.tf
#
# Declares every variable used teh values aren't here, they come frm terraform.tfvars.

variable "apic_url" {
  # type = string means not a number
  type        = string
  description = "Full URL of APIC sim"
}

variable "apic_username" {
  type        = string
  description = "aci sim login username."
}

variable "apic_password" {
  type        = string
  description = "APIC login password."
  # sensitive = true means the passowrd will not be priunted in terraform plan.
  sensitive   = true
}

# ── Access policy variables ──────────────────────────────────────────
#  The names and VLAN range in the access_policy mod

variable "vlan_pool_name" {
  type        = string
  description = "VLAN pool name"
}

variable "vlan_from" {
  # type = Whole number, not text.
  type        = number
  description = "First VLAN in the pool"
}

variable "vlan_to" {
  type        = number
  description = "Last VLAN in the pool"
}

variable "phys_domain_name" {
  type        = string
  description = "Name for the physical domain"
}

variable "aep_name" {
  type        = string
  description = "Name for the AEP"
}

variable "leaf_interface_profile_name" {
  type        = string
  description = "Name for the leaf interface profile"
}



# ── Fabric topology variables ─────────────────────────────────────────

variable "leaf_id" {
  type        = number
  description = "Node ID of the leaf."
}

variable "router_id" {
  type        = string
  description = "Router ID for the L3Out logical node"
}

variable "bgp_peer_ip" {
  type        = string
  description = "BGP peer IP"
}

variable "bgp_peer_asn" {
  type        = number
  description = "AS number of the BGP pee"
}

# ── Betwork variables ─────────────────────────────────────────

variable "vrf_name" {
    description = "name of vrf"
    type = string
    default = "common_vrf"
}
variable "bd_name" {
    description = "name of Brdidge domain"
    type = string
    default = "dns-bd"
}

variable "subnet_cidr"{
    description = "subnet for the Bridge domain"
    type = string
    default = "10.0.0.1/24"

}
variable "app_profile_name"{
    description = "application profile name"
    type = string
    default = "common-app"

}

variable "epg_name"{
    description = "end point group name"
    type = string
    default = "dns-epg"
    
}
