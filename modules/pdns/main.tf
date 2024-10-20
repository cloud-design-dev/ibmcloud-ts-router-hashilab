resource "ibm_resource_instance" "private_dns" {
  name              = "${var.prefix}-dns-instance"
  resource_group_id = var.resource_group_id
  location          = "global"
  service           = "dns-svcs"
  plan              = "standard-dns"
  tags              = var.tags
}

resource "ibm_dns_zone" "demo" {
  name        = var.dns_zone
  instance_id = ibm_resource_instance.private_dns.guid
  description = "demo-lab-zone"
  label       = "demo-lab-zone"
}

resource "ibm_dns_permitted_network" "demo" {
  instance_id = ibm_resource_instance.private_dns.guid
  zone_id     = ibm_dns_zone.demo.zone_id
  vpc_crn     = var.vpc_crn
  type        = "vpc"
}

resource "ibm_dns_custom_resolver" "demo" {
  name              = "${var.prefix}-dns-instance"
  instance_id       = var.resource_group_id
  high_availability = true
  enabled           = true
  locations {
    subnet_crn = var.subnet_crns[0]
    enabled    = true
  }
  locations {
    subnet_crn = var.subnet_crns[1]
    enabled    = true
  }
  locations {
    subnet_crn = var.subnet_crns[1]
    enabled    = true
  }
}
