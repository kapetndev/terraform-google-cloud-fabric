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

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

<!-- pyml disable-num-lines 4 md013 -->
| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.71.0 |
| [random](https://registry.terraform.io/providers/hashicorp/random/latest) | >= 3.5.1 |

## Resources

<!-- pyml disable-num-lines 4 md013 -->
| Name | Type |
|------|------|
| [`google_redis_instance.default`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [`random_id.instance_name`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance) | resource |

## Outputs

<!-- pyml disable-num-lines 4 md013 -->
| Name | Description |
|------|-------------|
| `instance_name` | The name of the Redis instance |
| `connection_name` | Hostname or IP address and port of the exposed Redis endpoint used by clients to connect to the service |
