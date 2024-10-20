variable "ibmcloud_api_key" {
  description = "The IBM Cloud API key to use for provisioning resources"
  type        = string
  sensitive   = true
}

variable "tailscale_api_key" {
  description = "The Tailscale API key"
  type        = string
  sensitive   = true
}

variable "tailscale_organization" {
  description = "The Tailscale tailnet Organization name. Can be found in the Tailscale admin console > Settings > General."
  type        = string
}

variable "project_prefix" {
  description = "The prefix to use for naming resources. If none is provided, a random string will be generated."
  type        = string
  default     = ""
}

variable "ibmcloud_region" {
  description = "The IBM Cloud region to use for provisioning VPCs and other resources."
  type        = string
}

variable "existing_resource_group" {
  description = "The IBM Cloud resource group to assign to the provisioned resources."
  type        = string
}

variable "existing_ssh_key" {
  description = "The name of an existing SSH key to use for provisioning resources. If one is not provided, a new key will be generated."
  type        = string
  default     = ""
}

variable "private_dns_zone" {
  description = "Name of the private DNS zone to create for the VPCs"
  type        = string
  default     = "internal.lab"
}

variable "allowed_ssh_ip" {
  description = "The IP address or CIDR block to allow SSH access from in to our Tailscale router instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "cluster_size" {
  description = "The number of worker nodes to create in the cluster."
  type        = number
  default     = 3
}

variable "dns_instance" {}
# variable "dns_instance_crn" {}
# variable "dns_instance_id" {}