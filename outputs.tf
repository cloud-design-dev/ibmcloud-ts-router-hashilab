output "tailscale_instance_ip" {
  value = module.tailscale_compute.compute_instance_ip
}

output "tailscale_advertised_subnet" {
  value = module.lab_vpc.compute_subnet_cidrs
}

output "hashilab_instance_ips" {
  value = [module.workload_compute[*].compute_instance_ip]
}

output "hashilab_loadbalancer_ip" {
  value = module.load_balancer.load_balancer_ip
}

# output "pdns_custom_resolver_ips" {
#   value = module.private_dns.pdns_custom_resolver_ips
# }