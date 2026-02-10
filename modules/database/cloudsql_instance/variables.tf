variable "activation_policy" {
  description = "Specifies when the instance should be active. Can be either `ALWAYS`, `NEVER` or `ON_DEMAND`. Default is `ALWAYS`."
  type        = string
  default     = "ALWAYS"
  nullable    = false
  validation {
    condition     = contains(["NEVER", "ON_DEMAND", "ALWAYS"], var.activation_policy)
    error_message = "`activation_policy` must be one of: `ALWAYS`, `NEVER` or `ON_DEMAND`."
  }
}

variable "availability_type" {
  description = "The availability type for the primary replica. Either `ZONAL` or `REGIONAL`. Default is `ZONAL`."
  type        = string
  default     = "ZONAL"
  nullable    = false
  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "`availability_type` must be one of `ZONAL` or `REGIONAL`."
  }
}

variable "backup_configuration" {
  description = <<EOF
The backup settings for primary instance. Will be automatically enabled if using MySQL with one or more replicas.

(Optional) enabled - Whether backups are enabled. Default is true.
(Optional) binary_log_enabled - Whether binary logging is enabled. Default is false.
(Optional) location - The location of the backup.
(Optional) log_retention_days - The number of days to retain transaction log files. Default is 7.
(Optional) point_in_time_recovery_enabled - Whether point in time recovery is enabled.
(Optional) retention_count - The number of backups to retain. Default is 7.
(Optional) start_time - The start time for the backup window, in 24 hour format. Default is "23:00". The time must be in the format "HH:MM" and must be in UTC.
EOF
  type = object({
    binary_log_enabled             = optional(bool, false)
    enabled                        = optional(bool, true)
    location                       = optional(string)
    log_retention_days             = optional(number, 7)
    point_in_time_recovery_enabled = optional(bool)
    retention_count                = optional(number, 7)
    start_time                     = optional(string, "23:00")
  })
  default  = {}
  nullable = false
}

variable "connector_enforcement" {
  description = "Specifies if connections must use Cloud SQL connectors."
  type        = string
  default     = null
}

variable "data_cache" {
  description = "Specifies if the data cache should be enabled. Only used for MYSQL and PostgreSQL."
  type        = bool
  default     = false
  nullable    = false
}

variable "database_version" {
  description = "The database type and version to create."
  type        = string
  nullable    = false
}

variable "databases" {
  description = <<EOF
A list of databases to create once the primary instance is created.

(Required) name - A unique name for the database.

(Optional) charset - The character set for the database. Default is UTF8 for MySQL and PostgreSQL, and SQL_Latin1_General_CP1_CI_AS for SQL Server.
(Optional) collation - The collation for the database. Default is en_US.UTF8 for MySQL and PostgreSQL, and SQL_Latin1_General_CP1_CI_AS for SQL Server.
EOF
  type = list(object({
    charset   = optional(string)
    collation = optional(string)
    name      = string
  }))
  default  = []
  nullable = false
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage capacity can be automatically increased. Default is 0, which specifies that there is no limit."
  type        = number
  default     = 0
  nullable    = false
}

variable "disk_size" {
  description = "The size of the disk attached to the primary instance, specified in GB. Set to null to enable autoresize."
  type        = number
  default     = null
}

variable "disk_type" {
  description = "The type of data disk: `PD_SSD` or `PD_HDD`. Default is `PD_SSD`."
  type        = string
  default     = "PD_SSD"
  nullable    = false
  validation {
    condition     = contains(["PD_SSD", "PD_HDD"], var.disk_type)
    error_message = "`disk_type` must be one of `PD_SSD` or `PD_HDD`."
  }
}

variable "edition" {
  description = "The edition of the primary instance, can be ENTERPRISE or ENTERPRISE_PLUS. Default is ENTERPRISE."
  type        = string
  default     = "ENTERPRISE"
  nullable    = false
  validation {
    condition     = contains(["ENTERPRISE", "ENTERPRISE_PLUS"], var.edition)
    error_message = "`edition` must be one of `ENTERPRISE` or `ENTERPRISE_PLUS`."
  }
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for the CMEK disk encryption of the primary instance."
  type        = string
  default     = null
}

variable "flags" {
  description = "A map of key/value database flag pairs for database-specific tuning."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "insights_config" {
  description = <<EOF
The Query Insights configuration. Default is to disable Query Insight

(Optional) query_plans_per_minute - The number of query plans to generate per minute. Default is 5.
(Optional) query_string_length - The maximum query string length. Default is 1024 characters. Default is 1024 characters.
(Optional) record_application_tags - Whether to record application tags. Default is false.
(Optional) record_client_address - Whether to record client addresses. Default is false.
EOF
  type = object({
    query_plans_per_minute  = optional(number, 5)
    query_string_length     = optional(number, 1024)
    record_application_tags = optional(bool, false)
    record_client_address   = optional(bool, false)
  })
  default = null
}

variable "labels" {
  description = "A map of user defined key/value label pairs to assign to the primary instance."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "location_preference" {
  description = <<EOF
The location preference for the primary instance. Useful for regional instances.

(Optional) zone - The preferred zone for the instance.
(Optional) secondary_zone - The preferred secondary zone for the instance. Only used if availability_type is REGIONAL.
EOF
  type = object({
    zone           = string
    secondary_zone = optional(string)
  })
  default = null
}

variable "machine_type" {
  description = "The machine type to create for the primary instance."
  type        = string
}

variable "maintenance_policy" {
  description = <<EOF
The maintenance window configuration and maintenance deny period (up to 90
days). Date format: 'yyyy-mm-dd'.

(Optional) maintenance_window - The maintenance window configuration.
(Optional) maintenance_window.day - Day of week (1-7), starting with Monday.
(Optional) maintenance_window.hour - Hour of day (0-23).
(Optional) maintenance_window.update_track - The update track. Either 'canary' or 'stable' (default).

(Optional) deny_maintenance_period - The maintenance deny period.
(Optional) deny_maintenance_period.end_date - The end date in YYYY-MM-DD format.
(Optional) deny_maintenance_period.start_date - The start date in YYYY-MM-DD format.
(Optional) deny_maintenance_period.start_time - The start time in HH:MM:SS format. Default is "00:00:00".
EOF
  type = object({
    maintenance_window = optional(object({
      day          = number
      hour         = number
      update_track = optional(string, "stable")
    }))
    deny_maintenance_period = optional(object({
      end_date   = string
      start_date = string
      start_time = optional(string, "00:00:00")
    }))
  })
  default  = {}
  nullable = false
  validation {
    condition = (
      try(var.maintenance_policy.maintenance_window, null) == null ? true : (
        # Maintenance window day validation below
        (
          var.maintenance_policy.maintenance_window.day >= 1 &&
          var.maintenance_policy.maintenance_window.day <= 7
        )
        # Maintenance window hour validation below
        && (
          var.maintenance_policy.maintenance_window.hour >= 0 &&
          var.maintenance_policy.maintenance_window.hour <= 23
        )
        && (try(var.maintenance_policy.maintenance_window.update_track, null) == null ? true :
        contains(["canary", "stable"], var.maintenance_policy.maintenance_window.update_track))
      )
    )
    error_message = "maintenance_policy: `maintenance_window.day` must be between 1 and 7, `maintenance_window.hour` must be between 0 and 23, and `maintenance_window.update_track` must be one of `stable` or `canary`."
  }
}

variable "name" {
  description = "Name of the primary instance. Used as a prefix for the generated instance name unless `override_name` is set."
  type        = string
  default     = null
}

variable "network_config" {
  description = <<EOF
The network configuration for the primary instance.

(Required) connectivity - The network connectivity configuration.
(Optional) connectivity.enable_private_path_for_services - Whether to enable private service access. Default is false.
(Optional) connectivity.public_ipv4 - Whether to enable public IPv4 access.

(Optional) connectivity.psa_config - The private service access configuration.
(Required) connectivity.psa_config.private_network - The private network to use.
(Optional) connectivity.psa_config.allocated_ip_range - The allocated IP range for private service access.

(Optional) authorized_networks - A map of authorized networks. Name => CIDR block.
EOF
  type = object({
    authorized_networks = optional(map(string), {})
    connectivity = object({
      enable_private_path_for_services = optional(bool, false)
      public_ipv4                      = optional(bool, false)
      psa_config = optional(object({
        private_network    = string
        allocated_ip_range = optional(string)
      }))
    })
  })
  nullable = false
}

variable "override_name" {
  description = "Fully qualified, authoritative name of the primary instance. When set, `name` is ignored and this value is used directly as the instance name with no suffix appended."
  type        = string
  default     = null
}

variable "password_validation_policy" {
  description = <<EOF
The password validation policy configuration for the primary instances.

(Optional) enabled - Whether the password policy is enabled. Defaults to true.
(Optional) change_interval - Password change interval in seconds. Only supported for PostgreSQL.
(Optional) default_complexity - Whether to enforce default complexity.
(Optional) disallow_username_substring - Whether to disallow username substring.
(Optional) min_length - Minimum password length.
(Optional) reuse_interval - Password reuse interval.
EOF
  type = object({
    change_interval             = optional(number) # Only supported for PostgreSQL
    default_complexity          = optional(bool)
    disallow_username_substring = optional(bool)
    enabled                     = optional(bool, true)
    min_length                  = optional(number)
    reuse_interval              = optional(number)
  })
  default = null
}

variable "prefix" {
  description = "An optional prefix prepended to the primary instance name. Has no effect when `override_name` is set. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "prevent_destroy" {
  description = "Sets `deletion_protection_enabled` on the Cloud SQL instance, which prevents the instance from being deleted via the GCP API or Console. This is distinct from Terraform's own `prevent_destroy` lifecycle rule — removing this flag and applying is sufficient to unblock a `terraform destroy`. Defaults to true."
  type        = bool
  default     = true
  nullable    = false
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "region" {
  description = "Region the primary instance will sit in."
  type        = string
  default     = null
}

variable "replicas" {
  description = <<EOF
A map of replicas to create for the primary instance, where the key is the replica name to be apended to the primary instance name.

(Optional) additional_flags - Additional database flags specific to this replica. These will be merged with the primary instance flags.
(Optional) additional_labels - Additional labels specific to this replica. These will be merged with the primary instance labels.
(Optional) availability_type - The availability type for this replica. If not specified, it will inherit the primary instance availability type.
(Optional) encryption_key_name - The encryption key name for this replica.
(Optional) machine_type - The machine type for this replica. If not specified, it will inherit the primary instance machine type.
(Optional) region - The region for this replica. If not specified, it will inherit the primary instance region.

(Optional) network_config - Network configuration specific to this replica. If not specified, it will inherit the primary instance network configuration.
(Optional) network_config.authorized_networks - Map of authorized networks. Name => CIDR block.
(Optional) network_config.connectivity - Network connectivity configuration.
(Optional) network_config.connectivity.enable_private_path_for_services - Whether to enable private service access.
(Optional) network_config.connectivity.public_ipv4 - Whether to enable public IPv4 access.
EOF
  type = map(object({
    additional_flags    = optional(map(string))
    additional_labels   = optional(map(string))
    availability_type   = optional(string)
    encryption_key_name = optional(string)
    machine_type        = optional(string)
    region              = optional(string)
    network_config = optional(object({
      authorized_networks = optional(map(string))
      connectivity = optional(object({
        enable_private_path_for_services = optional(bool)
        public_ipv4                      = optional(bool)
      }))
    }), null)
  }))
  default  = {}
  nullable = false
}

variable "root_password" {
  description = <<EOF
The root password of the Cloud SQL instance, or flag to create a random password. Required for MS SQL Server.

(Optional) password - The root password. Leave empty to generate a random password.
(Optional) random_password - Whether to generate a random password.
EOF
  type = object({
    password        = optional(string)
    random_password = optional(bool, false)
  })
  default  = {}
  nullable = false
  validation {
    condition     = !(var.root_password.password != null && var.root_password.random_password)
    error_message = "root_password: `password` and `random_password` are mutually exclusive. Set one or the other, not both."
  }
}

variable "ssl" {
  description = <<EOF
The SSL configuration for the primary instance.

(Optional) client_certificates - List of client certificate names to create.
(Optional) mode - SSL mode. Can be ALLOW_UNENCRYPTED_AND_ENCRYPTED, ENCRYPTED_ONLY, or TRUSTED_CLIENT_CERTIFICATE_REQUIRED.
EOF
  # More details @ https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance#ssl_mode
  type = object({
    client_certificates = optional(set(string), [])
    mode                = optional(string, "ENCRYPTED_ONLY")
  })
  default  = {}
  nullable = false
  validation {
    condition     = var.ssl.mode == null || contains(["ALLOW_UNENCRYPTED_AND_ENCRYPTED", "ENCRYPTED_ONLY", "TRUSTED_CLIENT_CERTIFICATE_REQUIRED"], var.ssl.mode)
    error_message = "ssl: `mode` must be one of `ALLOW_UNENCRYPTED_AND_ENCRYPTED`, `ENCRYPTED_ONLY`, or `TRUSTED_CLIENT_CERTIFICATE_REQUIRED`."
  }
}

variable "time_zone" {
  description = "The time_zone to be used by the database engine (supported only for SQL Server), in SQL Server timezone format."
  type        = string
  default     = null
}

variable "users" {
  description = <<EOF
A map of users to create in the primary instance. For MySQL, anything after the first `@` (if present) will be used as the user's host. Set PASSWORD to null if you want to get an autogenerated password. The user types available are: `BUILT_IN`, `CLOUD_IAM_USER` or `CLOUD_IAM_SERVICE_ACCOUNT`.

(Optional) password - The user password. Leave empty to generate a random password.
(Optional) type - The user type. Must be one of BUILT_IN, CLOUD_IAM_USER, or CLOUD_IAM_SERVICE_ACCOUNT.
EOF
  type = map(object({
    password = optional(string)
    type     = optional(string, "BUILT_IN")
  }))
  default  = {}
  nullable = false
  validation {
    condition     = alltrue([for user in var.users : contains(["BUILT_IN", "CLOUD_IAM_USER", "CLOUD_IAM_SERVICE_ACCOUNT"], user.type)])
    error_message = "users: `type` must be one of `BUILT_IN`, `CLOUD_IAM_USER`, or `CLOUD_IAM_SERVICE_ACCOUNT`."
  }
}
