output "pdns_zone_id" {
  value = ibm_dns_zone.demo.zone_id
}

output "pdns_instance_crn" {
  value = ibm_resource_instance.private_dns.crn
}