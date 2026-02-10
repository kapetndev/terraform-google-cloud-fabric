variable "alternative_zone" {
  description = "Alternative zone for the instance. Used for high availability when `tier` is `STANDARD_HA` — the instance will failover to this zone if the primary zone becomes unavailable."
  type        = string
  default     = null
}

variable "auth_enabled" {
  description = "Whether the Redis instance requires AUTH token authentication. Defaults to false. Note: Redis AUTH is a weak credential mechanism. Prefer enforcing private connectivity via `connect_mode = PRIVATE_SERVICE_ACCESS` and a restricted `authorized_network` rather than relying on AUTH as a primary security control."
  type        = bool
  default     = false
  nullable    = false
}

variable "authorized_network" {
  description = "Name or `self_link` of the VPC network to which the instance is connected. Required when `connect_mode` is `PRIVATE_SERVICE_ACCESS`. This should be the same VPC network that has a `google_service_networking_connection` established — i.e. the network passed to the `vpc_network` module with `private_services_access_ranges` configured."
  type        = string
  default     = null
}

variable "connect_mode" {
  description = "The connectivity mode for the instance. `PRIVATE_SERVICE_ACCESS` (default) uses the Private Services Access peering connection established via `servicenetworking.googleapis.com`, giving the instance a private IP from the allocated PSA range. `DIRECT_PEERING` is an older mechanism and is not recommended for new instances."
  type        = string
  default     = "PRIVATE_SERVICE_ACCESS"
  nullable    = false
  validation {
    condition     = contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.connect_mode)
    error_message = "`connect_mode` must be one of `DIRECT_PEERING` or `PRIVATE_SERVICE_ACCESS`."
  }
}

variable "labels" {
  description = "User defined key/value label pairs to assign to the instance."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "maintenance_policy" {
  description = <<EOF
Maintenance window configuration. When null, Google may perform maintenance at
any time.

(Optional) description - A human-readable description of the maintenance policy.

(Optional) maintenance_window - The recurring maintenance window.
(Required) maintenance_window.day - Day of week (1-7), starting with Monday.
(Required) maintenance_window.hour - Hour of day in UTC (0-23) at which the window starts.
EOF
  type = object({
    description = optional(string)
    maintenance_window = optional(object({
      day  = number
      hour = number
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
      )
    )
    error_message = "maintenance_policy: `maintenance_window.day` must be between 1 and 7 and `maintenance_window.hour` must be between 0 and 23."
  }
}

variable "memory_size_gb" {
  description = "The size of the Redis instance in GB. Must be at least 1. Defaults to 1."
  type        = number
  default     = 1
  nullable    = false
  validation {
    condition     = var.memory_size_gb >= 1
    error_message = "`memory_size_gb` must be at least 1 GB."
  }
}

variable "name" {
  description = "Name of the instance. Used as a prefix for the generated instance name unless `override_name` is set."
  type        = string
  default     = null
}

variable "override_name" {
  description = "Fully qualified, authoritative name of the instance. When set, `name` is ignored and this value is used directly as the instance name with no suffix appended."
  type        = string
  default     = null
}

variable "prefix" {
  description = "An optional prefix prepended to `name` when generating the instance name. Has no effect when `override_name` is set. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "project_id" {
  description = "The ID of the project in which to create the instance. Defaults to the provider project if not set."
  type        = string
  default     = null
}

variable "redis_version" {
  description = "The Redis version to use, e.g. `REDIS_7_0`. When null, GCP uses the latest supported version. See https://cloud.google.com/memorystore/docs/redis/supported-versions for available versions."
  type        = string
  default     = null
}

variable "region" {
  description = "The GCP region in which to create the instance."
  type        = string
  default     = null
}

variable "reserved_ip_range" {
  description = "Name of the `google_compute_global_address` resource (a key from `private_services_access_ranges` in the `vpc_network` module) from which the instance draws its private IP. When null, GCP allocates an IP from any available PSA range in the VPC. Setting this explicitly is recommended when multiple PSA ranges are allocated for different services to avoid unintended range exhaustion."
  type        = string
  default     = null
}

variable "tier" {
  description = "The service tier of the instance. `BASIC` (default) provides a standalone instance with no replication. `STANDARD_HA` provides a replicated instance with automatic failover to `alternative_zone`."
  type        = string
  default     = "BASIC"
  nullable    = false
  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.tier)
    error_message = "`tier` must be one of `BASIC` or `STANDARD_HA`."
  }
}

variable "zone" {
  description = "The primary zone in which to create the instance."
  type        = string
  default     = null
}
