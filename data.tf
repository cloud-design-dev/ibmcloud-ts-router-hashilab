data "ibm_is_zones" "regional" {
  region = var.ibmcloud_region
}

data "ibm_is_ssh_key" "sshkey" {
  count = var.existing_ssh_key != "" ? 1 : 0
  name  = var.existing_ssh_key
}

data "ibm_iam_account_settings" "iam_account_settings" {}
