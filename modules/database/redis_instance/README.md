# Google Cloud Redis Instance

This repository implements a sensible Redis configuration hosted on a Google
Cloud Platform Memorystore instance. It favours security above all else ensuring
that the instance can only be accessed from within the connected VPC.

## Usage

See the [examples](examples) directory for working examples for reference:

```hcl
module "my_redis_instance" {
  source  = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/database/redis_instance?ref=v0.1.0"
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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.9.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.9.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_redis_instance.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance) | resource |
| [random_id.instance_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | Name of the instance. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region the instance will sit in. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | Compute zone the instance will sit in | `string` | n/a | yes |
| <a name="input_alternative_zone"></a> [alternative\_zone](#input\_alternative\_zone) | Alternative zone for the instance. This is used for high availability configurations. | `string` | `null` | no |
| <a name="input_auth_enabled"></a> [auth\_enabled](#input\_auth\_enabled) | Whether the Redis instance requires authentication. Defaults to false. | `bool` | `false` | no |
| <a name="input_authorized_network"></a> [authorized\_network](#input\_authorized\_network) | Name or self\_link of the Google Compute Engine network to which the instance is connected. | `string` | `null` | no |
| <a name="input_connect_mode"></a> [connect\_mode](#input\_connect\_mode) | The mode in which the Redis instance is connected. Options are 'DIRECT\_PEERING' or 'PRIVATE\_SERVICE\_ACCESS'. | `string` | `"PRIVATE_SERVICE_ACCESS"` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | The authoritative name of the instance. Used instead of `name` variable. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of user defined key/value label pairs to assign to the instance. | `map(string)` | `{}` | no |
| <a name="input_maintenance_config"></a> [maintenance\_config](#input\_maintenance\_config) | The maintenance window configuration.<br/><br/>(Optional) description - A description of the maintenance window.<br/>(Optional) maintenance\_window - The maintenance window configuration.<br/>(Optional) maintenance\_window.day - Day of week (1-7), starting with Monday.<br/>(Optional) maintenance\_window.hour - Hour of day (0-23). | <pre>object({<br/>    description = optional(string, null)<br/>    maintenance_window = optional(object({<br/>      day  = number<br/>      hour = number<br/>    }), null)<br/>  })</pre> | `{}` | no |
| <a name="input_memory_size_gb"></a> [memory\_size\_gb](#input\_memory\_size\_gb) | The size of the Redis instance in GB. Defaults to 1. | `number` | `1` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix used to generate the primary instance name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_redis_version"></a> [redis\_version](#input\_redis\_version) | The instance version to create. Defaults to the latest supported version. | `string` | `null` | no |
| <a name="input_tier"></a> [tier](#input\_tier) | The tier of the Redis instance. Defaults to 'BASIC'. | `string` | `"BASIC"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_connection_name"></a> [connection\_name](#output\_connection\_name) | Hostname or IP address and port of the exposed Redis endpoint used by clients to connect to the service. |
| <a name="output_instance_name"></a> [instance\_name](#output\_instance\_name) | The name of the Redis instance. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
