# terraform-google-redis ![policy](https://github.com/StatusCakeDev/terraform-google-redis/workflows/policy/badge.svg)

This repository implements a sensible Redis configuration hosted on a Google
Cloud Platform Memorystore instance. It favours security above all else ensuring
that the instance can only be accessed from within the connected VPC.

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.71.0 |
| [random](https://registry.terraform.io/providers/hashicorp/random/latest) | >= 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [`google_redis_instance.default`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [`random_id.instance_name`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance) | resource |

## Outputs

| Name | Description |
|------|-------------|
| `instance_name` | The name of the Redis instance |
| `connection_name` | Hostname or IP address and port of the exposed Redis endpoint used by clients to connect to the service |
