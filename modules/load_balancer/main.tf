resource "ibm_is_lb" "vault_api" {
  name            = "${var.name}-vault-lb"
  subnets         = [var.subnet_id]
  profile         = "network-fixed"
  resource_group  = var.resource_group_id
  type            = "private"
  security_groups = [var.instance_security_group]
  dns {
    instance_crn = var.dns_instance_crn
    zone_id      = var.dns_zone_id
  }
}
