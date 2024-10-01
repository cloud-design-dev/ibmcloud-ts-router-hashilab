output "tailscale_instance_ip" {
  value = module.tailscale_compute.compute_instance_ip
}

output "zone1_subnet_cidr" {
  value = module.lab_vpc.zone1_subnet_cidr
}

