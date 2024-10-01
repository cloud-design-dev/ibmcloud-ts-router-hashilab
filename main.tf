# If no project prefix is defined, generate a random one 
resource "random_string" "prefix" {
  count   = var.project_prefix != "" ? 0 : 1
  length  = 4
  special = false
  numeric = false
  upper   = false
}

resource "tailscale_tailnet_key" "lab" {
  reusable      = false
  ephemeral     = true
  preauthorized = true
  expiry        = 7776000
  description   = "Demo tailscale key for lab"
}

# If an existing resource group is provided, this module returns the ID, otherwise it creates a new one and returns the ID
module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.1.5"
  resource_group_name          = var.existing_resource_group == null ? "${local.prefix}-resource-group" : null
  existing_resource_group_name = var.existing_resource_group
}

resource "tls_private_key" "ssh" {
  count     = var.existing_ssh_key != "" ? 0 : 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "ibm_is_ssh_key" "generated_key" {
  count          = var.existing_ssh_key != "" ? 0 : 1
  name           = "${local.prefix}-${var.ibmcloud_region}-sshkey"
  resource_group = module.resource_group.resource_group_id
  public_key     = tls_private_key.ssh.0.public_key_openssh
  tags           = local.tags
}

module "lab_vpc" {
  source            = "./modules/vpc"
  prefix            = local.prefix
  ibmcloud_region   = var.ibmcloud_region
  resource_group_id = module.resource_group.resource_group_id
  tags              = local.tags
  allowed_ssh_ip    = var.allowed_ssh_ip
}

module "tailscale_compute" {
  source                  = "./modules/compute"
  name                    = "${local.prefix}-ts-router"
  zone                    = local.vpc_zones[0].zone
  vpc_id                  = module.lab_vpc.vpc_id
  subnet_id               = module.lab_vpc.dmz_subnet_id
  resource_group_id       = module.resource_group.resource_group_id
  tags                    = concat(local.tags, ["demo:hashilab"])
  instance_security_group = module.lab_vpc.vpc_default_security_group
  cloud_init = templatefile("./ts-router.yaml", {
    tailscale_tailnet_key  = tailscale_tailnet_key.lab.key
    tailscale_zone1_subnet = module.lab_vpc.zone1_subnet_cidr
  })
  ssh_key_ids = local.ssh_key_ids
}

module "workload_compute" {
  count                   = var.cluster_size
  depends_on              = [module.tailscale_compute]
  source                  = "./modules/compute"
  name                    = "${local.prefix}-instance-${count.index}"
  zone                    = local.vpc_zones[0].zone
  vpc_id                  = module.lab_vpc.vpc_id
  subnet_id               = module.lab_vpc.zone1_subnet_id
  resource_group_id       = module.resource_group.resource_group_id
  tags                    = concat(local.tags, ["demo:hashilab"])
  instance_security_group = module.lab_vpc.hashilab_instance_security_group
  # cloud_init                 = file("./prod-compute.sh")
  cloud_init  = file("./prod-compute.sh")
  ssh_key_ids = local.ssh_key_ids
}

module "private_dns" {
  source            = "./modules/pdns"
  prefix            = local.prefix
  vpc_crn           = module.lab_vpc.vpc_crn
  resource_group_id = module.resource_group.resource_group_id
  dns_zone          = var.private_dns_zone
  tags              = local.tags
}

module "load_balancer" {
  depends_on              = [module.workload_compute]
  source                  = "./modules/load_balancer"
  dns_instance_crn        = module.private_dns.pdns_instance_crn
  dns_zone_id             = module.private_dns.pdns_zone_id
  subnet_id               = module.lab_vpc.zone1_subnet_id
  name                    = "${local.prefix}-prv-lb"
  resource_group_id       = module.resource_group.resource_group_id
  instance_security_group = module.lab_vpc.hashilab_instance_security_group
}

