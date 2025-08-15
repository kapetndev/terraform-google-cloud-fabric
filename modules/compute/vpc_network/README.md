# Virtual Private Cloud

Terraform module to create and manage VPC networks with configurable routing
modes, MTU settings, and IPv6 support. It manages subnets across regions, each
with secondary IP ranges, flow logging, and private Google API access.

The module also provisions Private Service Connect peering ranges, enabling
connections to managed GCP services such as Cloud SQL or Memorystore whilst
keeping resources isolated from the public internet.

## Usage

```hcl
module "my_vpc" {
  source = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/vpc_network?ref=v0.1.0"
  name   = "my-vpc"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.60.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_global_address.private_ip_allocations](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.service_networking_connection](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the network, which must be unique within the project. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])?`. | `string` | n/a | yes |
| <a name="input_auto_create_subnetworks"></a> [auto\_create\_subnetworks](#input\_auto\_create\_subnetworks) | Whether to create a subnetwork for each compute region automatically across the `10.128.0.0/9` address range. | `bool` | `false` | no |
| <a name="input_delete_default_routes_on_create"></a> [delete\_default\_routes\_on\_create](#input\_delete\_default\_routes\_on\_create) | Whether to delete the default routes (`0.0.0.0/0`) immediately after the network is created. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | A description of the network. | `string` | `null` | no |
| <a name="input_enable_ula_internal_ipv6"></a> [enable\_ula\_internal\_ipv6](#input\_enable\_ula\_internal\_ipv6) | Whether to enable Unique Local Address (ULA) internal IPv6 connectivity. If enabled, a /48 ULA IPv6 range will be automatically allocated from google defined ULA prefix fd20::/20 and associated with this network. | `bool` | `false` | no |
| <a name="input_internal_ipv6_range"></a> [internal\_ipv6\_range](#input\_internal\_ipv6\_range) | The internal IPv6 range in CIDR notation to be used by this network. The range must be a /48 prefix from google defined ULA prefix fd20::/20. If the field is not speficied, then a /48 range will be randomly allocated from fd20::/20 and returned via this field. | `string` | `null` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | The maximum transmission unit (MTU) in bytes. | `number` | `null` | no |
| <a name="input_network_firewall_policy_enforcement_order"></a> [network\_firewall\_policy\_enforcement\_order](#input\_network\_firewall\_policy\_enforcement\_order) | The order that firewall rules and firewall policies are evaluated. Default value is `AFTER_CLASSIC_FIREWALL`. Possible values are: `AFTER_CLASSIC_FIREWALL`, `BEFORE_CLASSIC_FIREWALL`. | `string` | `"AFTER_CLASSIC_FIREWALL"` | no |
| <a name="input_private_service_connect_ranges"></a> [private\_service\_connect\_ranges](#input\_private\_service\_connect\_ranges) | A map of IP address blocks (CIDR notation) that are allowed to use Private Service Connect. If the address is not given in CIDR notation, then a prefix length of 16 is used. | `map(string)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | The network-wide routing mode to use. If set to `REGIONAL`, this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. If set to `GLOBAL`, this network's cloud routers will advertise routes with all subnetworks of this network, across regions. Possible values are: `GLOBAL`, `REGIONAL`. | `string` | `"REGIONAL"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create in the network.<br/><br/>(Required) ip\_cidr\_range - The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, `10.0.0.0/8` or `192.168.0.0/16`. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported.<br/>(Required) name - The name of the resource, provided by the client when initially creating the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])?` which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash.<br/><br/>(Optional) description - A description of the subnet.<br/>(Optional) private\_ip\_google\_access - When enabled, virtual machines in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.<br/>(Optional) purpose - The purpose of the resource. This field can be either `PRIVATE_RFC_1918`, `INTERNAL_HTTPS_LOAD_BALANCER` or `REGIONAL_MANAGED_PROXY`. Defaults to `PRIVATE_RFC_1918`.<br/>(Optional) region - The GCP region for this subnetwork.<br/>(Optional) role - The role of subnetwork. Possible values are: `ACTIVE`, `BACKUP`. An `ACTIVE` subnetwork is one that is currently being used. A `BACKUP` subnetwork is one that is ready to be promoted to `ACTIVE` or is currently draining. Subnetwork role must be specified when `purpose` is set to `INTERNAL_HTTPS_LOAD_BALANCER` or `REGIONAL_MANAGED_PROXY`.<br/>(Optional) stack\_type - The stack type for this subnet to identify whether the IPv6 feature is enabled or not. If not specified `IPV4_ONLY` will be used. Possible values are: `IPV4_ONLY`, `IPV4_IPV6`.<br/>(Optional) log\_config - Denotes the logging options for the subnetwork flow logs. If logging is enabled logs will be exported to Stackdriver. This field cannot be set if the purpose of this subnetwork is `INTERNAL_HTTPS_LOAD_BALANCER`.<br/>(Optional) log\_config.aggregation\_interval - Toggles the aggregation interval for collecting flow logs. Default value is `INTERVAL_5_SEC`. Possible values are: `INTERVAL_5_SEC`, `INTERVAL_30_SEC`, `INTERVAL_1_MIN`, `INTERVAL_5_MIN`, `INTERVAL_10_MIN`, `INTERVAL_15_MIN`.<br/>(Optional) log\_config.filter\_expr - Export filter used to define which VPC flow logs should be logged, as as CEL expression. The default value is `true`, which evaluates to include everything.<br/>(Optional) log\_config.flow\_sampling - The value of the field must be in [0, 1]. Default is 0.5.<br/>(Optional) log\_config.metadata - Configures whether metadata fields should be added to the reported VPC flow logs. Default value is `INCLUDE_ALL_METADATA`. Possible values are: `EXCLUDE_ALL_METADATA`, `INCLUDE_ALL_METADATA`, `CUSTOM_METADATA`.<br/>(Optional) log\_config.metadata\_fields - List of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and `metadata` is set to `CUSTOM_METADATA`.<br/>(Optional) secondary\_ip\_ranges - An array of configurations for secondary IP ranges for virtual machine instances contained in this subnetwork.<br/>(Optional) secondary\_ip\_ranges.ip\_cidr\_range - The range of IP addresses belonging to this subnetwork secondary range. Provide this property when you create the subnetwork. Ranges must be unique and non-overlapping with all primary and secondary IP ranges within a network. Only IPv4 is supported.<br/>(Optional) secondary\_ip\_ranges.range\_name - The name associated with this subnetwork secondary range, used when adding an alias IP range to a VM instance. The name must be 1-63 characters long, and comply with RFC1035. The name must be unique within the subnetwork. | <pre>list(object({<br/>    description              = optional(string)<br/>    ip_cidr_range            = string<br/>    name                     = string<br/>    private_ip_google_access = optional(bool, false)<br/>    purpose                  = optional(string, "PRIVATE_RFC_1918")<br/>    region                   = optional(string)<br/>    role                     = optional(string)<br/>    stack_type               = optional(string, "IPV4_ONLY")<br/>    log_config = optional(object({<br/>      aggregation_interval = optional(string, "INTERVAL_5_SEC")<br/>      filter_expr          = optional(string, "true")<br/>      flow_sampling        = optional(number, 0.5)<br/>      metadata             = optional(string, "INCLUDE_ALL_METADATA")<br/>      metadata_fields      = optional(list(string))<br/>    }))<br/>    secondary_ip_ranges = optional(list(object({<br/>      ip_cidr_range = string<br/>      range_name    = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The network ID. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | The subnets in the network. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
