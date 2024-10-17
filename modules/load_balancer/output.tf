output "load_balancer_hostname" {
  value = ibm_is_lb.hashilab.hostname
}

output "load_balancer_ip" {
  value = ibm_is_lb.hashilab.private_ip[0].address
}

output "loadbalancer_id" {
  value = ibm_is_lb.hashilab.id
}