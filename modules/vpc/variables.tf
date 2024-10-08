variable "prefix" {
  description = "Prefix to add to all deployed resources"
  type        = string
}

variable "ibmcloud_region" {
  description = "The region to create the VPC in"
  type        = string
}

variable "resource_group_id" {}
variable "tags" {}

variable "classic_access" {
  description = "Whether to enable classic access for the VPC"
  type        = bool
  default     = false
}

variable "default_address_prefix" {
  description = "The default address prefix for the VPC"
  type        = string
  default     = "auto"
}

variable "allowed_ssh_ip" {
  description = "The IP address or CIDR block to allow SSH access from in to our Tailscale router instance."
  type        = string
  default     = "0.0.0.0/0"
}

variable "creation_tag" {
  description = "Tag to add to all resources created by this module"
  type        = string
}