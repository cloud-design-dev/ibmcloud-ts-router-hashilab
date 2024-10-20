locals {

  zones = length(data.ibm_is_zones.regional.zones)
  vpc_zones = {
    for zone in range(local.zones) : zone => {
      zone = "${var.ibmcloud_region}-${zone + 1}"
    }
  }
}

resource "ibm_is_vpc" "demo" {
  name                        = "${var.prefix}-vpc"
  resource_group              = var.resource_group_id
  classic_access              = var.classic_access
  address_prefix_management   = var.default_address_prefix
  default_network_acl_name    = "${var.prefix}-default-acl"
  default_security_group_name = "${var.prefix}-default-sg"
  default_routing_table_name  = "${var.prefix}-default-rt"
  tags                        = concat(var.tags, ["${var.creation_tag}"])
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

module "add_rules_to_default_vpc_security_group" {
  depends_on                   = [ibm_is_vpc.demo]
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.6.2"
  add_ibm_cloud_internal_rules = true
  use_existing_security_group  = true
  existing_security_group_name = "${var.prefix}-default-sg"
  security_group_rules = [
    {
      name      = "allow-ts-cidr-ssh-inbound"
      direction = "inbound"
      remote    = "100.64.0.0/10"
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "allow-icmp-inbound"
      direction = "inbound"
      icmp = {
        type = 8
      }
      remote = "100.64.0.0/10"
    },
    {
      name      = "allow-homelab-ssh-inbound"
      direction = "inbound"
      remote    = var.allowed_ssh_ip
      tcp = {
        port_min = 22
        port_max = 22
      }
    }
  ]
  tags = var.tags
}



resource "ibm_is_public_gateway" "demo" {
  count          = length(data.ibm_is_zones.regional.zones)
  name           = "${var.prefix}-pubgw-z${count.index + 1}"
  resource_group = var.resource_group_id
  vpc            = ibm_is_vpc.demo.id
  zone           = local.vpc_zones[count.index].zone
  tags           = concat(var.tags, ["zone:${local.vpc_zones[count.index].zone}", "${var.creation_tag}"])
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "ibm_is_subnet" "dmz" {
  name                     = "${var.prefix}-dmz-subnet-z1"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.demo.id
  zone                     = local.vpc_zones[0].zone
  total_ipv4_address_count = "32"
  tags                     = concat(var.tags, ["zone:${local.vpc_zones[0].zone}", "${var.creation_tag}"])
  public_gateway           = ibm_is_public_gateway.demo[0].id
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

resource "ibm_is_subnet" "compute" {
  count                    = length(data.ibm_is_zones.regional.zones)
  name                     = "${var.prefix}-compute-subnet-z${count.index + 1}"
  resource_group           = var.resource_group_id
  vpc                      = ibm_is_vpc.demo.id
  zone                     = local.vpc_zones[count.index].zone
  total_ipv4_address_count = "64"
  public_gateway           = ibm_is_public_gateway.demo[count.index].id
  tags                     = concat(var.tags, ["zone:${local.vpc_zones[count.index].zone}", "${var.creation_tag}"])
  lifecycle {
    ignore_changes = [
      tags,
    ]
  }
}

module "hashilab_instance_security_group" {
  depends_on                   = [ibm_is_subnet.dmz]
  source                       = "terraform-ibm-modules/security-group/ibm"
  version                      = "2.6.2"
  add_ibm_cloud_internal_rules = true
  vpc_id                       = ibm_is_vpc.demo.id
  security_group_name          = "${var.prefix}-hashilab-sg"
  security_group_rules = [
    {
      name      = "allow-vault-inbound"
      direction = "inbound"
      remote    = "0.0.0.0/0"
      tcp = {
        port_min = 8200
        port_max = 8201
      }
    },
    {
      name      = "allow-icmp-inbound"
      direction = "inbound"
      icmp = {
        type = 8
      }
      remote = "100.64.0.0/10"
    },
    {
      name      = "allow-homelab-ssh-inbound"
      direction = "inbound"
      remote    = var.allowed_ssh_ip
      tcp = {
        port_min = 22
        port_max = 22
      }
    },
    {
      name      = "allow-all-from-dmz"
      direction = "inbound"
      remote    = ibm_is_subnet.dmz.ipv4_cidr_block
    },
    {
      name      = "allow-all-outbound"
      direction = "outbound"
      remote    = "0.0.0.0/0"
    }
  ]
  tags = var.tags
}