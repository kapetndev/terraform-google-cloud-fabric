# Google Virtual Private Cloud (VPC)

Terraform module to create and manage Google Cloud Platform compute resources.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "my_vpc" {
  source = "git::https://github.com/kapetndev/terraform-google-compute.git?ref=v0.1.0"
  name   = "my-vpc"
}
```

## Examples

- [minimal-network](../../examples/minimal-network) - Create a VPC with the
  minimum configuration.

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.71.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [`google_compute_global_address.private_ip_allocations[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [`google_compute_network.vpc`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [`google_compute_subnetwork.subnets[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [`google_service_networking_connection.service_networking_connection`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The name of the network, which must be unique within the project. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])?` | `string` | | yes |
| `auto_create_subnetworks` | Whether to create a subnetwork for each compute region automatically across the `10.128.0.0/9` address range | `bool` | `false` | no |
| `delete_default_routes_on_create` | Whether to delete the default routes (`0.0.0.0/0`) immediately after the network is created | `bool` | `false` | no |
| `description` | A description of the network | `string` | `null` | no |
| `mtu` | The maximum transmission unit (MTU) in bytes | `number` | `null` | no |
| `network_firewall_policy_enforcement_order` | The order that firewall rules and firewall policies are evaluated. Default value is `AFTER_CLASSIC_FIREWALL`. Possible values are: `AFTER_CLASSIC_FIREWALL`, `BEFORE_CLASSIC_FIREWALL` | `string` | `AFTER_CLASSIC_FIREWALL` | no |
| `private_service_connect_ranges` | A map of IP address blocks (CIDR notation) that are allowed to use Private Service Connect. If the address is not given in CIDR notation, then a prefix length of 16 is used | `map(string)` | `{}` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
| `routing_mode` | The network-wide routing mode to use. If set to `REGIONAL`, this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. If set to `GLOBAL`, this network's cloud routers will advertise routes with all subnetworks of this network, across regions. Possible values are: `GLOBAL`, `REGIONAL` | `string` | `REGIONAL` | no |
| `subnets` | Subnets to create in the network | `list(object{...})` | `[]` | no |
| `subnets[*].name` | The name of the resource, provided by the client when initially creating the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])?` which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash | `string` | | yes |
| `subnets[*].ip_cidr_range` | The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, `10.0.0.0/8` or `192.168.0.0/16`. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported | `string` | | yes |
| `subnets[*].description` | A description of the subnet | `string` | `null` | no |
| `subnets[*].log_config` | Denotes the logging options for the subnetwork flow logs. If logging is enabled logs will be exported to Stackdriver. This field cannot be set if the purpose of this subnetwork is `INTERNAL_HTTPS_LOAD_BALANCER` | `object{...}` | `null` | no |
| `subnets[*].log_config.aggregation_interval` | Toggles the aggregation interval for collecting flow logs. Default value is `INTERVAL_5_SEC`. Possible values are: `INTERVAL_5_SEC`, `INTERVAL_30_SEC`, `INTERVAL_1_MIN`, `INTERVAL_5_MIN`, `INTERVAL_10_MIN`, `INTERVAL_15_MIN` | `string` | `INTERVAL_5_SEC` | no |
| `subnets[*].log_config.filter_expr` | Export filter used to define which VPC flow logs should be logged, as as CEL expression. The default value is `true`, which evaluates to include everything | `string` | `true` | no |
| `subnets[*].log_config.flow_sampling` | The value of the field must be in [0, 1] | `number` | `0.5` | no |
| `subnets[*].log_config.metadata_fields` | Configures whether metadata fields should be added to the reported VPC flow logs. Default value is `INCLUDE_ALL_METADATA`. Possible values are: `EXCLUDE_ALL_METADATA`, `INCLUDE_ALL_METADATA`, `CUSTOM_METADATA` | `string` | `INCLUDE_ALL_METADATA` | no |
| `subnets[*].log_config.metadata` | List of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and `metadata` is set to `CUSTOM_METADATA` | `list(string)` | `[]` | no |
| `subnets[*].private_ip_google_access` | When enabled, virtual machines in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access | `bool` | `false` | no |
| `subnets[*].purpose` | The purpose of the resource. This field can be either `PRIVATE_RFC_1918`, `INTERNAL_HTTPS_LOAD_BALANCER` or `REGIONAL_MANAGED_PROXY`. Defaults to `PRIVATE_RFC_1918` | `string` | `PRIVATE_RFC_1918` | no |
| `subnets[*].region` | The GCP region for this subnetwork | `string` | `null` | no |
| `subnets[*].role` | The role of subnetwork. The value can be set to `ACTIVE` or `BACKUP`. An `ACTIVE` subnetwork is one that is currently being used. A `BACKUP` subnetwork is one that is ready to be promoted to `ACTIVE` or is currently draining. Subnetwork role must be specified when `purpose` is set to `INTERNAL_HTTPS_LOAD_BALANCER` or `REGIONAL_MANAGED_PROXY`. Possible values are: `ACTIVE`, `BACKUP` | `string` | `null` | no |
| `subnets[*].secondary_ip_ranges` | An array of configurations for secondary IP ranges for virtual machine instances contained in this subnetwork | `list(object{...})` | `[]` | no |
| `subnets[*].secondary_ip_ranges[*].ip_cidr_range` | The range of IP addresses belonging to this subnetwork secondary range. Provide this property when you create the subnetwork. Ranges must be unique and non-overlapping with all primary and secondary IP ranges within a network. Only IPv4 is supported | `string` | | yes |
| `subnets[*].secondary_ip_ranges[*].range_name` | The name associated with this subnetwork secondary range, used when adding an alias IP range to a VM instance. The name must be 1-63 characters long, and comply with RFC1035. The name must be unique within the subnetwork | `string` | | yes |
| `subnets[*].stack_type` | The stack type for this subnet to identify whether the IPv6 feature is enabled or not. If not specified `IPV4_ONLY` will be used. Possible values are: `IPV4_ONLY`, `IPV4_IPV6` | `string` | `IPV4_ONLY` | no |

## Outputs

| Name | Description |
|------|-------------|
| `id` | The network ID |
| `subnets` | The subnets in the network |
