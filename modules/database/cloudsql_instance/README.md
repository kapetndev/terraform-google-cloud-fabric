# Cloud SQL Instance

Terraform module to create and manage Cloud SQL instances for MySQL, PostgreSQL,
or SQL Server with the following capabilities:

- Configurable machine types, disk autoresizing, and high availability options
- Private connectivity via Private Service Connect or public IPv4 with
  authorised network whitelisting
- Automated backups with point-in-time recovery, binary logging for MySQL, and
  configurable retention policies
- Read replicas across regions with independent machine types, network
  configurations, and database flags
- Database users with automatic password generation, supporting MySQL host-based
  users and PostgreSQL service account integration
- Password validation policies with complexity requirements and rotation
  intervals

## Usage

```hcl
module "my_database_instance" {
  source           = "github.com/kapetndev/terraform-google-cloud-fabric//modules/database/cloudsql_instance?ref=v0.1.0"
  collation        = "en_US.UTF-8"
  database_version = "POSTGRES_17"
  machine_type     = "db-f1-micro"
  name             = "my-database-instance"
  region           = "europe-west2"

  databases = [
    "my_database",
  ]

  network_config = {
    connectivity = {
      ipv4_enabled = true
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 5.6.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.6.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_sql_database.databases](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.primary](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_database_instance.replicas](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_ssl_cert.client_certificates](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_ssl_cert) | resource |
| [google_sql_user.users](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [random_id.database_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_password.passwords](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [random_password.root_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | The database type and version to create. | `string` | n/a | yes |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to create for the primary instnace. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the primary instance. | `string` | n/a | yes |
| <a name="input_network_config"></a> [network\_config](#input\_network\_config) | The network configuration for the primary instance.<br/><br/>(Required) connectivity - The network connectivity configuration.<br/>(Optional) connectivity.enable\_private\_path\_for\_services - Whether to enable private service access. Default is false.<br/>(Optional) connectivity.psa\_config - The private service access configuration.<br/>(Required) connectivity.psa\_config.private\_network - The private network to use.<br/>(Optional) connectivity.psa\_config.allocated\_ip\_range - The allocated IP range for private service access.<br/>(Optional) connectivity.public\_ipv4 - Whether to enable public IPv4 access.<br/><br/>(Optional) authorized\_networks - A map of authorized networks. Name => CIDR block. | <pre>object({<br/>    authorized_networks = optional(map(string), {})<br/>    connectivity = object({<br/>      enable_private_path_for_services = optional(bool, false)<br/>      public_ipv4                      = optional(bool, false)<br/>      psa_config = optional(object({<br/>        private_network    = string<br/>        allocated_ip_range = optional(string)<br/>      }))<br/>    })<br/>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region the primary instance will sit in. | `string` | n/a | yes |
| <a name="input_activation_policy"></a> [activation\_policy](#input\_activation\_policy) | Specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`. Default is `ALWAYS`. | `string` | `"ALWAYS"` | no |
| <a name="input_availability_type"></a> [availability\_type](#input\_availability\_type) | The availability type for the primary replica. Either `ZONAL` or `REGIONAL`. Default is `ZONAL`. | `string` | `"ZONAL"` | no |
| <a name="input_backup_configuration"></a> [backup\_configuration](#input\_backup\_configuration) | The backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas.<br/><br/>(Optional) enabled - Whether backups are enabled. Default is false.<br/>(Optional) binary\_log\_enabled - Whether binary logging is enabled. Default is false.<br/>(Optional) location - The location of the backup.<br/>(Optional) log\_retention\_days - The number of days to retain transaction log files. Default is 7.<br/>(Optional) point\_in\_time\_recovery\_enabled - Whether point in time recovery is enabled.<br/>(Optional) retention\_count - The number of backups to retain. Default is 7.<br/>(Optional) start\_time - The start time for the backup window, in 24 hour format. Default is "23:00". The time must be in the format "HH:MM" and must be in UTC. | <pre>object({<br/>    enabled                        = optional(bool, false)<br/>    binary_log_enabled             = optional(bool, false)<br/>    location                       = optional(string)<br/>    log_retention_days             = optional(number, 7)<br/>    point_in_time_recovery_enabled = optional(bool)<br/>    retention_count                = optional(number, 7)<br/>    start_time                     = optional(string, "23:00")<br/>  })</pre> | <pre>{<br/>  "binary_log_enabled": false,<br/>  "enabled": false,<br/>  "location": null,<br/>  "log_retention_days": 7,<br/>  "point_in_time_recovery_enabled": null,<br/>  "retention_count": 7,<br/>  "start_time": "23:00"<br/>}</pre> | no |
| <a name="input_connector_enforcement"></a> [connector\_enforcement](#input\_connector\_enforcement) | Specifies if connections must use Cloud SQL connectors. | `string` | `null` | no |
| <a name="input_data_cache"></a> [data\_cache](#input\_data\_cache) | Specifies if the data cache should be enabled. Only used for MYSQL and PostgreSQL. | `bool` | `false` | no |
| <a name="input_databases"></a> [databases](#input\_databases) | A list of databases to create once the primary instance is created.<br/><br/>(Required) name - A unique name for the database.<br/><br/>(Optional) charset - The character set for the database. Default is UTF8 for MySQL and PostgreSQL, and SQL\_Latin1\_General\_CP1\_CI\_AS for SQL Server.<br/>(Optional) collation - The collation for the database. Default is en\_US.UTF8 for MySQL and PostgreSQL, and SQL\_Latin1\_General\_CP1\_CI\_AS for SQL Server. | <pre>list(object({<br/>    charset   = optional(string)<br/>    collation = optional(string)<br/>    name      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | The authoritative name of the primary instance. Used instead of `name` variable. | `string` | `null` | no |
| <a name="input_disk_autoresize_limit"></a> [disk\_autoresize\_limit](#input\_disk\_autoresize\_limit) | The maximum size to which storage capacity can be automatically increased. Default is 0, which specifies that there is no limit. | `number` | `0` | no |
| <a name="input_disk_size"></a> [disk\_size](#input\_disk\_size) | The size of the disk attached to the primary instance, specified in GB. Set to null to enable autoresize. | `number` | `null` | no |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | The type of data disk: `PD_SSD` or `PD_HDD`. Default is `PD_SSD`. | `string` | `"PD_SSD"` | no |
| <a name="input_edition"></a> [edition](#input\_edition) | The edition of the primary instance, can be ENTERPRISE or ENTERPRISE\_PLUS. Default is ENTERPRISE. | `string` | `"ENTERPRISE"` | no |
| <a name="input_encryption_key_name"></a> [encryption\_key\_name](#input\_encryption\_key\_name) | The full path to the encryption key used for the CMEK disk encryption of the primary instance. | `string` | `null` | no |
| <a name="input_flags"></a> [flags](#input\_flags) | A map of key/value database flag pairs for database-specific tuning. | `map(string)` | `{}` | no |
| <a name="input_insights_config"></a> [insights\_config](#input\_insights\_config) | The Query Insights configuration. Default is to disable Query Insights.<br/><br/>(Optional) query\_plans\_per\_minute - The number of query plans to generate per minute. Default is 5.<br/>(Optional) query\_string\_length - The maximum query string length. Default is 1024 characters. Default is 1024 characters.<br/>(Optional) record\_application\_tags - Whether to record application tags. Default is false.<br/>(Optional) record\_client\_address - Whether to record client addresses. Default is false. | <pre>object({<br/>    query_plans_per_minute  = optional(number, 5)<br/>    query_string_length     = optional(number, 1024)<br/>    record_application_tags = optional(bool, false)<br/>    record_client_address   = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of user defined key/value label pairs to assign to the primary instance. | `map(string)` | `{}` | no |
| <a name="input_location_preference"></a> [location\_preference](#input\_location\_preference) | The location preference for the primary instance. Useful for regional instances.<br/><br/>(Optional) zone - The preferred zone for the instance.<br/>(Optional) secondary\_zones - List of secondary zones for the instance. | <pre>object({<br/>    zone           = string<br/>    secondary_zone = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_maintenance_config"></a> [maintenance\_config](#input\_maintenance\_config) | The maintenance window configuration and maintenance deny period (up to 90 days). Date format: 'yyyy-mm-dd'.<br/><br/>(Optional) maintenance\_window - The maintenance window configuration.<br/>(Optional) maintenance\_window.day - Day of week (1-7), starting with Monday.<br/>(Optional) maintenance\_window.hour - Hour of day (0-23).<br/>(Optional) maintenance\_window.update\_track - The update track. Either 'canary' or 'stable'.<br/>(Optional) deny\_maintenance\_period - The maintenance deny period.<br/>(Optional) deny\_maintenance\_period.end\_date - The end date in YYYY-MM-DD format.<br/>(Optional) deny\_maintenance\_period.start\_date - The start date in YYYY-MM-DD format.<br/>(Optional) deny\_maintenance\_period.start\_time - The start time in HH:MM:SS format. Default is "00:00:00". | <pre>object({<br/>    maintenance_window = optional(object({<br/>      day          = number<br/>      hour         = number<br/>      update_track = optional(string, null)<br/>    }), null)<br/>    deny_maintenance_period = optional(object({<br/>      end_date   = string<br/>      start_date = string<br/>      start_time = optional(string, "00:00:00")<br/>    }), null)<br/>  })</pre> | `{}` | no |
| <a name="input_password_validation_policy"></a> [password\_validation\_policy](#input\_password\_validation\_policy) | The password validation policy configuration for the primary instances.<br/><br/>(Optional) change\_interval - Password change interval in seconds. Only supported for PostgreSQL.<br/>(Optional) default\_complexity - Whether to enforce default complexity.<br/>(Optional) disallow\_username\_substring - Whether to disallow username substring.<br/>(Optional) min\_length - Minimum password length.<br/>(Optional) reuse\_interval - Password reuse interval. | <pre>object({<br/>    # change interval is only supported for postgresql<br/>    change_interval             = optional(number)<br/>    default_complexity          = optional(bool)<br/>    disallow_username_substring = optional(bool)<br/>    min_length                  = optional(number)<br/>    reuse_interval              = optional(number)<br/>  })</pre> | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix used to generate the primary instance name. | `string` | `null` | no |
| <a name="input_prevent_destroy"></a> [prevent\_destroy](#input\_prevent\_destroy) | Prevent the primary instance and any replicas from being destroyed. | `bool` | `true` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_replicas"></a> [replicas](#input\_replicas) | A map of replicas to create for the primary instance, where the key is the replica name to be apended to the primary instance name.<br/><br/>(Optional) additional\_flags - Additional database flags specific to this replica. These will be merged with the primary instance flags.<br/>(Optional) additional\_labels - Additional labels specific to this replica. These will be merged with the primary instance labels.<br/>(Optional) availability\_type - The availability type for this replica. If not specified, it will inherit the primary instance availability type.<br/>(Optional) encryption\_key\_name - The encryption key name for this replica.<br/>(Optional) machine\_type - The machine type for this replica. If not specified, it will inherit the primary instance machine type.<br/>(Optional) region - The region for this replica. If not specified, it will inherit the primary instance region.<br/>(Optional) network\_config - Network configuration specific to this replica. If not specified, it will inherit the primary instance network configuration.<br/>(Optional) network\_config.authorized\_networks - Map of authorized networks. Name => CIDR block.<br/>(Optional) network\_config.connectivity - Network connectivity configuration.<br/>(Optional) network\_config.connectivity.enable\_private\_path\_for\_services - Whether to enable private service access.<br/>(Optional) network\_config.connectivity.public\_ipv4 - Whether to enable public IPv4 access. | <pre>map(object({<br/>    additional_flags    = optional(map(string))<br/>    additional_labels   = optional(map(string))<br/>    availability_type   = optional(string)<br/>    encryption_key_name = optional(string)<br/>    machine_type        = optional(string)<br/>    region              = optional(string)<br/>    network_config = optional(object({<br/>      authorized_networks = optional(map(string))<br/>      connectivity = optional(object({<br/>        enable_private_path_for_services = optional(bool)<br/>        public_ipv4                      = optional(bool)<br/>      }))<br/>    }), null)<br/>  }))</pre> | `{}` | no |
| <a name="input_root_password"></a> [root\_password](#input\_root\_password) | The root password of the Cloud SQL instance, or flag to create a random password. Required for MS SQL Server.<br/><br/>(Optional) password - The root password. Leave empty to generate a random password.<br/>(Optional) random\_password - Whether to generate a random password. | <pre>object({<br/>    password        = optional(string)<br/>    random_password = optional(bool, false)<br/>  })</pre> | `{}` | no |
| <a name="input_ssl"></a> [ssl](#input\_ssl) | The SSL configuration for the primary instance.<br/><br/>(Optional) client\_certificates - List of client certificate names to create.<br/>(Optional) mode - SSL mode. Can be ALLOW\_UNENCRYPTED\_AND\_ENCRYPTED, ENCRYPTED\_ONLY, or TRUSTED\_CLIENT\_CERTIFICATE\_REQUIRED. | <pre>object({<br/>    client_certificates = optional(set(string), [])<br/>    mode                = optional(string, "ALLOW_UNENCRYPTED_AND_ENCRYPTED")<br/>  })</pre> | `{}` | no |
| <a name="input_time_zone"></a> [time\_zone](#input\_time\_zone) | The time\_zone to be used by the database engine (supported only for SQL Server), in SQL Server timezone format. | `string` | `null` | no |
| <a name="input_users"></a> [users](#input\_users) | A map of users to create in the primary instance. For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: `BUILT_IN`, `CLOUD_IAM_USER` or `CLOUD_IAM_SERVICE_ACCOUNT`.<br/><br/>(Optional) password - The user password. Leave empty to generate a random password.<br/>(Optional) type - The user type. Must be one of BUILT\_IN, CLOUD\_IAM\_USER, or CLOUD\_IAM\_SERVICE\_ACCOUNT. | <pre>map(object({<br/>    password = optional(string)<br/>    type     = optional(string, "BUILT_IN")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_certificates"></a> [client\_certificates](#output\_client\_certificates) | The CA Certificate used to connect to the SQL Instance via SSL. |
| <a name="output_connection_name"></a> [connection\_name](#output\_connection\_name) | Connection name of the primary instance. |
| <a name="output_connection_names"></a> [connection\_names](#output\_connection\_names) | Connection names of all instances. |
| <a name="output_dns_name"></a> [dns\_name](#output\_dns\_name) | The dns name of the instance. |
| <a name="output_dns_names"></a> [dns\_names](#output\_dns\_names) | Dns names of all instances. |
| <a name="output_id"></a> [id](#output\_id) | Fully qualified primary instance id. |
| <a name="output_ids"></a> [ids](#output\_ids) | Fully qualified ids of all instances. |
| <a name="output_ip"></a> [ip](#output\_ip) | IP address of the primary instance. |
| <a name="output_ips"></a> [ips](#output\_ips) | IP addresses of all instances. |
| <a name="output_name"></a> [name](#output\_name) | Name of the primary instance. |
| <a name="output_names"></a> [names](#output\_names) | Names of all instances. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
