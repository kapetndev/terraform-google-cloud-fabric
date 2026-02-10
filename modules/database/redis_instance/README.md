# Cloud Redis Instance

Terraform module to create and manage managed Redis instances with configurable
memory sizes and version selection. It supports high availability configurations
with alternative zone placement for STANDARD_HA tier instances, connecting to
VPC networks via Private Service Access or direct peering.

## Usage

```hcl
module "my_redis_instance" {
  source  = "github.com/kapetndev/terraform-google-cloud-fabric//modules/database/redis_instance?ref=v0.1.0"
  name    = "my-redis-instance"
  region  = "europe-west2"
  zone    = "europe-west2-a"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_redis_instance.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance) | resource |
| [random_id.instance_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alternative_zone"></a> [alternative\_zone](#input\_alternative\_zone) | Alternative zone for the instance. Used for high availability when `tier` is `STANDARD_HA` — the instance will failover to this zone if the primary zone becomes unavailable. | `string` | `null` | no |
| <a name="input_auth_enabled"></a> [auth\_enabled](#input\_auth\_enabled) | Whether the Redis instance requires AUTH token authentication. Defaults to false. Note: Redis AUTH is a weak credential mechanism. Prefer enforcing private connectivity via `connect_mode = PRIVATE_SERVICE_ACCESS` and a restricted `authorized_network` rather than relying on AUTH as a primary security control. | `bool` | `false` | no |
| <a name="input_authorized_network"></a> [authorized\_network](#input\_authorized\_network) | Name or `self_link` of the VPC network to which the instance is connected. Required when `connect_mode` is `PRIVATE_SERVICE_ACCESS`. This should be the same VPC network that has a `google_service_networking_connection` established — i.e. the network passed to the `vpc_network` module with `private_services_access_ranges` configured. | `string` | `null` | no |
| <a name="input_connect_mode"></a> [connect\_mode](#input\_connect\_mode) | The connectivity mode for the instance. `PRIVATE_SERVICE_ACCESS` (default) uses the Private Services Access peering connection established via `servicenetworking.googleapis.com`, giving the instance a private IP from the allocated PSA range. `DIRECT_PEERING` is an older mechanism and is not recommended for new instances. | `string` | `"PRIVATE_SERVICE_ACCESS"` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | Fully qualified, authoritative name of the instance. When set, `name` is ignored and this value is used directly as the instance name with no suffix appended. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | User defined key/value label pairs to assign to the instance. | `map(string)` | `{}` | no |
| <a name="input_maintenance_config"></a> [maintenance\_config](#input\_maintenance\_config) | Maintenance window configuration. When null, Google may perform maintenance at any time.<br/><br/>(Optional) description - A human-readable description of the maintenance policy.<br/><br/>(Optional) maintenance\_window - The recurring maintenance window.<br/>(Required) maintenance\_window.day - Day of week (1-7), starting with Monday.<br/>(Required) maintenance\_window.hour - Hour of day in UTC (0-23) at which the window starts. | <pre>object({<br/>    description = optional(string)<br/>    maintenance_window = optional(object({<br/>      day  = number<br/>      hour = number<br/>    }))<br/>  })</pre> | `{}` | no |
| <a name="input_memory_size_gb"></a> [memory\_size\_gb](#input\_memory\_size\_gb) | The size of the Redis instance in GB. Must be at least 1. Defaults to 1. | `number` | `1` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance. Used as a prefix for the generated instance name unless `descriptive_name` is set. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix prepended to `name` when generating the instance name. Has no effect when `descriptive_name` is set. Cannot be an empty string — use null to omit. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which to create the instance. Defaults to the provider project if not set. | `string` | `null` | no |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | The Redis version to use, e.g. `REDIS_7_0`. When null, GCP uses the latest supported version. See https://cloud.google.com/memorystore/docs/redis/supported-versions for available versions. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | The GCP region in which to create the instance. | `string` | `null` | no |
| <a name="input_reserved_ip_range"></a> [reserved\_ip\_range](#input\_reserved\_ip\_range) | Name of the `google_compute_global_address` resource (a key from `private_services_access_ranges` in the `vpc_network` module) from which the instance draws its private IP. When null, GCP allocates an IP from any available PSA range in the VPC. Setting this explicitly is recommended when multiple PSA ranges are allocated for different services to avoid unintended range exhaustion. | `string` | `null` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | The service tier of the instance. `BASIC` (default) provides a standalone instance with no replication. `STANDARD_HA` provides a replicated instance with automatic failover to `alternative_zone`. | `string` | `"BASIC"` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | The primary zone in which to create the instance. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The host:port endpoint of the instance. Convenience output combining `host` and `port` for use in connection strings. |
| <a name="output_host"></a> [host](#output\_host) | The private IP address of the instance. Use this to configure application connection strings. |
| <a name="output_id"></a> [id](#output\_id) | The fully qualified resource ID of the instance. |
| <a name="output_name"></a> [name](#output\_name) | The name of the instance as known to the GCP API. |
| <a name="output_port"></a> [port](#output\_port) | The port number the instance is listening on. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
