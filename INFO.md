<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | 1.69.0 |
| <a name="requirement_tailscale"></a> [tailscale](#requirement\_tailscale) | 0.16.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_ibm"></a> [ibm](#provider\_ibm) | 1.69.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.6.3 |
| <a name="provider_tailscale"></a> [tailscale](#provider\_tailscale) | 0.16.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lab_vpc"></a> [lab\_vpc](#module\_lab\_vpc) | ./modules/vpc | n/a |
| <a name="module_load_balancer"></a> [load\_balancer](#module\_load\_balancer) | ./modules/load_balancer | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | terraform-ibm-modules/resource-group/ibm | 1.1.5 |
| <a name="module_tailscale_compute"></a> [tailscale\_compute](#module\_tailscale\_compute) | ./modules/compute | n/a |
| <a name="module_workload_compute"></a> [workload\_compute](#module\_workload\_compute) | ./modules/compute | n/a |

## Resources

| Name | Type |
|------|------|
| [ibm_is_lb_listener.vault_api](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.0/docs/resources/is_lb_listener) | resource |
| [ibm_is_lb_pool.vault](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.0/docs/resources/is_lb_pool) | resource |
| [ibm_is_lb_pool_member.attachment](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.0/docs/resources/is_lb_pool_member) | resource |
| [ibm_is_ssh_key.generated_key](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.0/docs/resources/is_ssh_key) | resource |
| [random_string.prefix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/string) | resource |
| [tailscale_tailnet_key.lab](https://registry.terraform.io/providers/tailscale/tailscale/0.16.2/docs/resources/tailnet_key) | resource |
| [tls_private_key.ssh](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [ibm_is_ssh_key.sshkey](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.0/docs/data-sources/is_ssh_key) | data source |
| [ibm_is_zones.regional](https://registry.terraform.io/providers/IBM-Cloud/ibm/1.69.0/docs/data-sources/is_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ssh_ip"></a> [allowed\_ssh\_ip](#input\_allowed\_ssh\_ip) | The IP address or CIDR block to allow SSH access from in to our Tailscale router instance. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_cluster_size"></a> [cluster\_size](#input\_cluster\_size) | The number of worker nodes to create in the cluster. | `number` | `3` | no |
| <a name="input_existing_resource_group"></a> [existing\_resource\_group](#input\_existing\_resource\_group) | The IBM Cloud resource group to assign to the provisioned resources. | `string` | n/a | yes |
| <a name="input_existing_ssh_key"></a> [existing\_ssh\_key](#input\_existing\_ssh\_key) | The name of an existing SSH key to use for provisioning resources. If one is not provided, a new key will be generated. | `string` | `""` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key to use for provisioning resources | `string` | n/a | yes |
| <a name="input_ibmcloud_region"></a> [ibmcloud\_region](#input\_ibmcloud\_region) | The IBM Cloud region to use for provisioning VPCs and other resources. | `string` | n/a | yes |
| <a name="input_private_dns_zone"></a> [private\_dns\_zone](#input\_private\_dns\_zone) | Name of the private DNS zone to create for the VPCs | `string` | `"internal.lab"` | no |
| <a name="input_project_prefix"></a> [project\_prefix](#input\_project\_prefix) | The prefix to use for naming resources. If none is provided, a random string will be generated. | `string` | `""` | no |
| <a name="input_tailscale_api_key"></a> [tailscale\_api\_key](#input\_tailscale\_api\_key) | The Tailscale API key | `string` | n/a | yes |
| <a name="input_tailscale_organization"></a> [tailscale\_organization](#input\_tailscale\_organization) | The Tailscale tailnet Organization name. Can be found in the Tailscale admin console > Settings > General. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_tailscale_advertised_subnet"></a> [tailscale\_advertised\_subnet](#output\_tailscale\_advertised\_subnet) | n/a |
| <a name="output_tailscale_instance_ip"></a> [tailscale\_instance\_ip](#output\_tailscale\_instance\_ip) | n/a |
| <a name="output_vault_instance_ips"></a> [vault\_instance\_ips](#output\_vault\_instance\_ips) | n/a |
| <a name="output_vault_loadbalancer_ip"></a> [vault\_loadbalancer\_ip](#output\_vault\_loadbalancer\_ip) | n/a |
<!-- END_TF_DOCS -->