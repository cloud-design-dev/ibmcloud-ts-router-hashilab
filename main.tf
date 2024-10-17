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
  creation_tag      = "created_at:${local.deploy_timestamp}"
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
    tailscale_tailnet_key        = tailscale_tailnet_key.lab.key
    tailscale_advertised_subnets = join(",", module.lab_vpc.compute_subnet_cidrs)
  })
  ssh_key_ids = local.ssh_key_ids
}

module "private_dns" {
  source            = "./modules/pdns"
  prefix            = local.prefix
  subnet_crns       = [module.lab_vpc.compute_subnet_crns[0], module.lab_vpc.compute_subnet_crns[1], module.lab_vpc.compute_subnet_crns[2]]
  vpc_crn           = module.lab_vpc.vpc_crn
  resource_group_id = module.resource_group.resource_group_id
  dns_zone          = var.private_dns_zone
  tags              = local.tags
}

module "load_balancer" {
  depends_on              = [module.private_dns]
  source                  = "./modules/load_balancer"
  dns_instance_crn        = data.ibm_resource_instance.dns_svc.id
  dns_zone_id             = data.ibm_dns_zones.dns_svc.dns_zones[0].zone_id
  subnet_id               = module.lab_vpc.dmz_subnet_id
  name                    = "${local.prefix}-prv-lb"
  resource_group_id       = module.resource_group.resource_group_id
  instance_security_group = module.lab_vpc.hashilab_instance_security_group
}

module "workload_compute" {
  depends_on              = [module.load_balancer]
  count                   = var.cluster_size
  source                  = "./modules/compute"
  name                    = "${local.prefix}-instance-${count.index}"
  zone                    = local.vpc_zones[0].zone
  vpc_id                  = module.lab_vpc.vpc_id
  subnet_id               = module.lab_vpc.compute_subnet_ids[0]
  resource_group_id       = module.resource_group.resource_group_id
  tags                    = concat(local.tags, ["demo:hashilab"])
  instance_security_group = module.lab_vpc.hashilab_instance_security_group
  # cloud_init                 = file("./prod-compute.sh")
  cloud_init = templatefile("./prod-compute.sh", {
    load_balancer_ip  = module.load_balancer.load_balancer_ip
    instance_hostname = "${local.prefix}-instance-${count.index}"
  })
  ssh_key_ids = local.ssh_key_ids
}

resource "ibm_is_lb_pool" "vault" {
  name                     = "${local.prefix}-vault-pool"
  lb                       = module.load_balancer.loadbalancer_id
  algorithm                = "round_robin"
  protocol                 = "tcp"
  health_delay             = 60
  health_retries           = 5
  health_timeout           = 30
  health_type              = "tcp"
  health_monitor_port      = 8200
  session_persistence_type = "source_ip"
}

resource "ibm_is_lb_pool" "consul" {
  name                     = "${local.prefix}-consul-pool"
  lb                       = module.load_balancer.loadbalancer_id
  algorithm                = "round_robin"
  protocol                 = "tcp"
  health_delay             = 60
  health_retries           = 5
  health_timeout           = 30
  health_type              = "tcp"
  health_monitor_port      = 8500
  session_persistence_type = "source_ip"
}

resource "ibm_is_lb_listener" "vault_api" {
  lb           = module.load_balancer.loadbalancer_id
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.vault.id
  port         = 8200
}

resource "ibm_is_lb_listener" "consul_api" {
  lb           = module.load_balancer.loadbalancer_id
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.consul.id
  port         = 8500
}

resource "ibm_is_lb_pool_member" "vault_attachment" {
  count     = var.cluster_size
  lb        = module.load_balancer.loadbalancer_id
  pool      = element(split("/", ibm_is_lb_pool.vault.id), 1)
  port      = 8200
  target_id = module.workload_compute[count.index].compute_instance_id
}

