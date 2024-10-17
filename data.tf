data "ibm_is_zones" "regional" {
  region = var.ibmcloud_region
}

data "ibm_is_ssh_key" "sshkey" {
  count = var.existing_ssh_key != "" ? 1 : 0
  name  = var.existing_ssh_key
}


data "ibm_resource_instance" "dns_svc" {
  name              = var.dns_instance
  location          = "global"
  resource_group_id = module.resource_group.resource_group_id
  service           = "dns-svcs"
}


data "ibm_dns_zones" "dns_svc" {
  instance_id = data.ibm_resource_instance.dns_svc.guid
}