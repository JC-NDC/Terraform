# ==============================================================
# SECTION 1: ACCESS POLICIES
#
# VLAN pool -> physical domain -> AEP -> Leaf interface profile -> port selector -> port block
# ==============================================================


# VLAN pool ─────────────────────────────────────────────────
#
# resource "aci_vlan_pool" = the ACI object type to create "this" = what we call it inside Terraform. Arbitrary.


resource "aci_vlan_pool" "sim_vlan_pool" {
  # var.vlan_pool_name = look up the variable declared in the variables.tf and the value comes from terraform.tfvars
  name       = var.vlan_pool_name

    alloc_mode = "static"
}



# VLAN range ─────────────────────────────────────────────────
# The actual range of VLANs in the pool.

resource "aci_ranges" "sim_vlan_ranges" {

#references the vlan pool .id created above

  vlan_pool_dn = aci_vlan_pool.sim_vlan_pool.id

  from       = "vlan-${var.vlan_from}"
  to         = "vlan-${var.vlan_to}"
  alloc_mode = "static"
}


# ── Physical domain ────────────────────────────────────────────
# Tells ACI which VLAN pool to use for the domain associated to physical end devices

resource "aci_physical_domain" "sim_physical_dom" {
  name = var.phys_domain_name

  # Links the domain to the VLAN pool.
  relation_infra_rs_vlan_ns = aci_vlan_pool.sim_vlan_pool.id
}


# ── AEP (Attachable Entity Profile) ───────────────────────────
# The AEP links the interface policies to domains.  interfaces using this AEP are allowed to carry traffic for the domain domains
resource "aci_attachable_access_entity_profile" "sim_aep" {
  name = var.aep_name
}


# ── AEP to domain binding ──────────────────────────────────────
#
# Links the AEP to the physical domain

resource "aci_aaep_to_domain" "sim_aep_to_domain" {
  attachable_access_entity_profile_dn = aci_attachable_access_entity_profile.sim_aep.id
  domain_dn                           = aci_physical_domain.sim_physical_dom.id
}


# ── Leaf interface profile ─────────────────────────────────────
#
resource "aci_leaf_interface_profile" "sim_int_profile" {
  name = var.leaf_interface_profile_name
}


# ── Port selector ────────
# Selects which ports within the interface profile the policy applies to

resource "aci_access_port_selector" "sim_port_selector" {
  leaf_interface_profile_dn = aci_leaf_interface_profile.sim_int_profile.id
  name                      = "all_ports"

  access_port_selector_type = "ALL"
}


# ── Port block ─────────────────────────────────────────────────
# Defines the specific port range within the selector.
# Card 1 ports 1-48 covers a standard 48-port linecard.
# In SIM this does not map to real hardware but must exist.

resource "aci_access_port_block" "sim_port_block" {
  access_port_selector_dn = aci_access_port_selector.sim_port_selector.id
  name      = "block1"
  from_card = "1"
  to_card   = "1"
  from_port = "1"
  to_port   = "48"
}
# ── Common tenant ───────────────────────────────────────

# CHain: data lookup for tenant -> VRF -> BD -> SUBNET -> AP -> EPG -> DOMAON

data "aci_tenant" "common" {
  name = "common"
}

resource "aci_vrf" "common_vrf" {
    tenant_dn = data.aci_tenant.common.id
    name = var.vrf_name
}


#Bind the vrf to the Bridge Domain

resource "aci_bridge_domain" "dns_bd"{
    tenant_dn = data.aci_tenant.common.id
    name = var.bd_name
    relation_fv_rs_ctx = aci_vrf.common_vrf.id
    }

resource "aci_subnet" "dns_bd_subnet"{
    parent_dn = aci_bridge_domain.dns_bd.id
    ip = var.subnet_cidr
    scope = ["public"]
}

resource "aci_application_profile" "common_app" {
 tenant_dn = data.aci_tenant.common.id
  name      = var.app_profile_name

}

resource "aci_application_epg" "dns_epg" {
  application_profile_dn = aci_application_profile.common_app.id
  name                   = var.epg_name
  relation_fv_rs_bd      = aci_bridge_domain.dns_bd.id
}

resource "aci_epg_to_domain" "common_dns" {
  application_epg_dn = aci_application_epg.dns_epg.id
  tdn                = aci_physical_domain.sim_physical_dom.id
}

# ── Contracts ───────────────────────────────────────

# web-to-app allows web EPGS to reach app EPG on TCP80 and 443
# web EPG is th ecomsumer of the contract and app EPG provides ot

resource "aci_filter" "web_to_app"{
    tenant_dn = data.aci_tenant.common.id
    name = "web-to-app-filter"
}

#Fitler for TCP 80
resource "aci_filter_entry" "web_to_app_80" {
    filter_dn = aci_filter.web_to_app
    name = "tcp-80"
    ether_t = "ip"
    prot = "tcp"
    d_from_port = "80"
    d_to_port = "80"

}

#Filter entry for TCP port 443
resource "aci_filter_entry" "web_to_app_443" {
  filter_dn   = aci_filter.web_to_app.id
  name        = "tcp-443"
  ether_t     = "ip"
  prot = "tcp"
  d_from_port = "443"
  d_to_port   = "443"
}

# The contract this is what the EPGs will reference
resource "aci_contract" "web_to_app" {
  tenant_dn = data.aci_tenant.common.id
  name      = "web-to-app"
  scope     = "global"
}

# Subject links the contract to the filter
resource "aci_contract_subject" "web_to_app" {
  contract_dn = aci_contract.web_to_app.id
  name        = "web-to-app-subj"
  relation_vz_rs_subj_filt_att = [aci_filter.web_to_app.id]
}

#  Contract 2 2: app-to-db
# Allows app EPGs to reach db EPGs on TCP 5432 this will be published to PROD tenant

resource "aci_filter" "app_to_db" {
  tenant_dn = data.aci_tenant.common.id
  name      = "app-to-db-filter"
}

resource "aci_filter_entry" "app_to_db_5432" {
  filter_dn   = aci_filter.app_to_db.id
  name        = "tcp-5432"
  ether_t     = "ip"
  prot = "tcp"
  d_from_port = "5432"
  d_to_port = "5432"
}

# The contract this is what the EPGs will reference
resource "aci_contract" "app_to_db"{
    tenant_dn = data.aci_tenant.common.id
    name = "app-to-db"
    scope = "global"
}
#subkect this links the contract to teh filter
resource "aci_contract_subject" app_to_db{
    contract_dn = aci_contract.app_to_db.id
name = "app_to_db_subj"
relation_vz_rs_subj_filt_att = aci_filter.app_to_db
}



