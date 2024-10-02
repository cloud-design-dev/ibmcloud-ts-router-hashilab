output "tailscale_instance_ip" {
  value = module.tailscale_compute.compute_instance_ip
}

output "tailscale_advertised_subnet" {
  value = module.lab_vpc.zone1_subnet_cidr
}

output "vault_instance_ips" {
  value = [module.workload_compute[*].compute_instance_ip]
}

output "vault_loadbalancer_ip" {
  value = module.load_balancer.load_balancer_ip
}
