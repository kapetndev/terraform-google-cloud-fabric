# Virtual Private Cloud

Terraform module to create and manage VPC networks with configurable routing
modes, MTU settings, and IPv6 support. It manages subnets across regions, each
with secondary IP ranges, flow logging, and private Google API access.

The module also provisions Private Services Access peering ranges, enabling
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_global_address.private_services_access_ranges](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_network.network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_network) | resource |
| [google_compute_subnetwork.subnets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_subnetwork) | resource |
| [google_service_networking_connection.private_services_access](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_networking_connection) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the VPC network. Must be 1-63 characters long, lowercase, and match `[a-z]([-a-z0-9]*[a-z0-9])?`. Must be unique within the project. | `string` | n/a | yes |
| <a name="input_auto_create_subnetworks"></a> [auto\_create\_subnetworks](#input\_auto\_create\_subnetworks) | When true, GCP automatically creates a subnetwork in each region across the `10.128.0.0/9` address range. Defaults to false — subnets should be managed explicitly via the subnets variable. | `bool` | `false` | no |
| <a name="input_delete_default_routes_on_create"></a> [delete\_default\_routes\_on\_create](#input\_delete\_default\_routes\_on\_create) | When true, the default internet route (`0.0.0.0/0`) is deleted immediately after the network is created. Recommended when all egress should be controlled explicitly via Cloud NAT or Cloud Router rather than permitting arbitrary internet egress. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | A human-readable description of the network resource. | `string` | `null` | no |
| <a name="input_enable_ula_internal_ipv6"></a> [enable\_ula\_internal\_ipv6](#input\_enable\_ula\_internal\_ipv6) | Enable Unique Local Address (ULA) internal IPv6 on the network. When enabled, a `/48` ULA range is allocated from Google's `fd20::/20` prefix and assigned to the network. | `bool` | `false` | no |
| <a name="input_internal_ipv6_range"></a> [internal\_ipv6\_range](#input\_internal\_ipv6\_range) | A specific `/48` ULA IPv6 range from Google's `fd20::/20` prefix to assign to the network. Only valid when `enable_ula_internal_ipv6` is true. When null, GCP assigns a range automatically. | `string` | `null` | no |
| <a name="input_mtu"></a> [mtu](#input\_mtu) | Maximum transmission unit in bytes. Must be between 1300 and 8896. Use 1500 for standard Ethernet, or up to 8896 for Jumbo Frames on supported machine types. When null, GCP uses its default of 1460. | `number` | `null` | no |
| <a name="input_network_firewall_policy_enforcement_order"></a> [network\_firewall\_policy\_enforcement\_order](#input\_network\_firewall\_policy\_enforcement\_order) | Evaluation order of firewall policies relative to classic (per-network) firewall rules. `AFTER_CLASSIC_FIREWALL` evaluates network firewall policies after classic rules; `BEFORE_CLASSIC_FIREWALL` evaluates them first. | `string` | `"AFTER_CLASSIC_FIREWALL"` | no |
| <a name="input_private_services_access_ranges"></a> [private\_services\_access\_ranges](#input\_private\_services\_access\_ranges) | IP address ranges (in CIDR notation) to reserve for Private Services Access.<br/>Private Services Access allocates these ranges in your VPC and peers them with<br/>Google's service producer network via `servicenetworking.googleapis.com`,<br/>enabling private connectivity to managed services such as Cloud SQL,<br/>Memorystore, and AlloyDB without traffic traversing the public internet.<br/><br/>Each entry is a map of name => CIDR, e.g.:<br/>  { "google-managed-services" = "10.100.0.0/16" }<br/><br/>Note: this is distinct from Private Service Connect, which uses forwarding rules<br/>and service attachments to reach Google APIs by private IP. | `map(string)` | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project in which to create the network. Defaults to the provider project if not set. | `string` | `null` | no |
| <a name="input_routing_mode"></a> [routing\_mode](#input\_routing\_mode) | Network-wide routing mode. `REGIONAL` advertises only routes within the same region as the Cloud Router. `GLOBAL` advertises routes across all regions, required for global load balancing and multi-region topologies. | `string` | `"REGIONAL"` | no |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | Subnets to create within the network. Multiple subnets may share a name across<br/>different regions - the resource key is region/name to ensure uniqueness.<br/><br/>(Required) name - Subnet name. Must be 1-63 characters, lowercase, matching `[a-z]([-a-z0-9]*[a-z0-9])?`.<br/>(Required) ip\_cidr\_range - Primary IPv4 CIDR range. Must be unique and non-overlapping within the network.<br/>(Required) region - GCP region in which to create the subnet.<br/><br/>(Optional) description - Human-readable description.<br/>(Optional) private\_ip\_google\_access - Allow VMs without external IPs to reach Google APIs via internal routing. Defaults to true — required for GKE nodes, Cloud SQL clients, and any workload that calls Google APIs without a public IP or Cloud NAT.<br/>(Optional) purpose - Subnet purpose. One of PRIVATE, REGIONAL\_MANAGED\_PROXY, GLOBAL\_MANAGED\_PROXY, PRIVATE\_SERVICE\_CONNECT, PEER\_MIGRATION, or PRIVATE\_NAT. Defaults to PRIVATE.<br/>(Optional) role - ACTIVE or BACKUP. Required when purpose is REGIONAL\_MANAGED\_PROXY or GLOBAL\_MANAGED\_PROXY.<br/>(Optional) stack\_type - IPV4\_ONLY (default) or IPV4\_IPV6.<br/>(Optional) ipv6\_access\_type - INTERNAL or EXTERNAL. Only valid when stack\_type is IPV4\_IPV6.<br/><br/>(Optional) log\_config - Enable VPC flow log export for this subnet. When null, flow logging is disabled. Cannot be set when purpose is INTERNAL\_HTTPS\_LOAD\_BALANCER.<br/>(Optional) log\_config.aggregation\_interval - Log aggregation window. One of INTERVAL\_5\_SEC (default), INTERVAL\_30\_SEC, INTERVAL\_1\_MIN, INTERVAL\_5\_MIN, INTERVAL\_10\_MIN, or INTERVAL\_15\_MIN.<br/>(Optional) log\_config.filter\_expr - CEL expression to filter exported logs. Defaults to "true" (export all).<br/>(Optional) log\_config.flow\_sampling - Fraction of flow logs to export, between 0 and 1. Defaults to 0.5.<br/>(Optional) log\_config.metadata - Metadata fields to include. One of INCLUDE\_ALL\_METADATA (default), EXCLUDE\_ALL\_METADATA, or CUSTOM\_METADATA.<br/>(Optional) log\_config.metadata\_fields - Specific metadata fields to export. Only valid when metadata is CUSTOM\_METADATA.<br/><br/>(Optional) secondary\_ip\_ranges - Additional IP ranges for alias IPs, e.g. for GKE Pod and Service CIDRs. Each range must be unique and non-overlapping within the network.<br/>(Required) secondary\_ip\_ranges.range\_name - Name for the secondary range.<br/>(Required) secondary\_ip\_ranges.ip\_cidr\_range - CIDR range for the secondary range. | <pre>list(object({<br/>    description              = optional(string)<br/>    ip_cidr_range            = string<br/>    ipv6_access_type         = optional(string)<br/>    name                     = string<br/>    private_ip_google_access = optional(bool, true)<br/>    purpose                  = optional(string, "PRIVATE")<br/>    region                   = string<br/>    role                     = optional(string)<br/>    stack_type               = optional(string, "IPV4_ONLY")<br/>    log_config = optional(object({<br/>      aggregation_interval = optional(string, "INTERVAL_5_SEC")<br/>      filter_expr          = optional(string, "true")<br/>      flow_sampling        = optional(number, 0.5)<br/>      metadata             = optional(string, "INCLUDE_ALL_METADATA")<br/>      metadata_fields      = optional(list(string))<br/>    }))<br/>    secondary_ip_ranges = optional(list(object({<br/>      ip_cidr_range = string<br/>      range_name    = string<br/>    })), [])<br/>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the network. |
| <a name="output_name"></a> [name](#output\_name) | The name of the network. Use this when referencing the network from other modules, such as the gke\_cluster or vpc\_firewall modules which take a network name as input. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | The URI of the network. Use this when a resource requires a fully qualified network reference rather than a short name. |
| <a name="output_subnets"></a> [subnets](#output\_subnets) | Map of created subnets keyed by region/name, exposing the attributes most commonly needed by downstream resources. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
