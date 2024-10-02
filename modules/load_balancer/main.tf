resource "ibm_is_lb" "vault" {
  name            = var.name
  subnets         = [var.subnet_id]
  profile         = "network-fixed"
  resource_group  = var.resource_group_id
  type            = "private"
  security_groups = [var.instance_security_group]
}
