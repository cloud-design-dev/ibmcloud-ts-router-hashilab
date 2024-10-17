output "vpc_id" {
  value = ibm_is_vpc.demo.id
}

output "vpc_crn" {
  value = ibm_is_vpc.demo.crn
}

output "vpc_default_security_group" {
  value = ibm_is_vpc.demo.default_security_group
}

output "hashilab_instance_security_group" {
  value = module.hashilab_instance_security_group.security_group_id
}

output "dmz_subnet_id" {
  value = ibm_is_subnet.dmz.id
}

output "compute_subnet_ids" {
  value = ibm_is_subnet.compute[*].id
}

output "dmz_subnet_crn" {
  value = ibm_is_subnet.dmz.crn
}

output "compute_subnet_crns" {
  value = ibm_is_subnet.compute[*].crn
}

output "dmz_subnet_cidr" {
  value = ibm_is_subnet.dmz.ipv4_cidr_block
}

output "compute_subnet_cidrs" {
  value = ibm_is_subnet.compute[*].ipv4_cidr_block
}



