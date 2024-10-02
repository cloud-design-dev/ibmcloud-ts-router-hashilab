output "load_balancer_hostname" {
  value = ibm_is_lb.vault.hostname
}

output "load_balancer_ip" {
  value = ibm_is_lb.vault.private_ip[0].address
}

output "loadbalancer_id" {
  value = ibm_is_lb.vault.id
}