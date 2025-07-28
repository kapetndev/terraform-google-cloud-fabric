variable "alternative_zone" {
  description = "Alternative zone for the instance. This is used for high availability configurations."
  type        = string
  default     = null
}

variable "auth_enabled" {
  description = "Whether the Redis instance requires authentication. Defaults to false."
  type        = bool
  default     = false
}

variable "authorized_network" {
  description = "Name or self_link of the Google Compute Engine network to which the instance is connected."
  type        = string
  default     = null
  nullable    = true
}

variable "connect_mode" {
  description = "The mode in which the Redis instance is connected. Options are 'DIRECT_PEERING' or 'PRIVATE_SERVICE_ACCESS'."
  type        = string
  default     = "PRIVATE_SERVICE_ACCESS"
  validation {
    condition     = contains(["DIRECT_PEERING", "PRIVATE_SERVICE_ACCESS"], var.connect_mode)
    error_message = "connect_mode must be either 'DIRECT_PEERING' or 'PRIVATE_SERVICE_ACCESS'."
  }
}

variable "descriptive_name" {
  description = "The authoritative name of the instance. Used instead of `name` variable."
  type        = string
  default     = null
}

variable "labels" {
  description = "A map of user defined key/value label pairs to assign to the instance."
  type        = map(string)
  default     = {}
}

variable "maintenance_config" {
  description = <<EOF
The maintenance window configuration.

(Optional) description - A description of the maintenance window.
(Optional) maintenance_window - The maintenance window configuration.
(Optional) maintenance_window.day - Day of week (1-7), starting with Monday.
(Optional) maintenance_window.hour - Hour of day (0-23).
EOF
  type = object({
    description = optional(string, null)
    maintenance_window = optional(object({
      day  = number
      hour = number
    }), null)
  })
  default = {}
  validation {
    condition = (
      try(var.maintenance_config.maintenance_window, null) == null ? true : (
        # Maintenance window day validation below
        var.maintenance_config.maintenance_window.day >= 1 &&
        var.maintenance_config.maintenance_window.day <= 7 &&
        # Maintenance window hour validation below
        var.maintenance_config.maintenance_window.hour >= 0 &&
        var.maintenance_config.maintenance_window.hour <= 23
      )
    )
    error_message = "Maintenance window day must be between 1 and 7, maintenance window hour must be between 0 and 23."
  }
}

variable "memory_size_gb" {
  description = "The size of the Redis instance in GB. Defaults to 1."
  type        = number
  default     = 1
  validation {
    condition     = var.memory_size_gb >= 1
    error_message = "Memory size must be at least 1 GB."
  }
}

variable "name" {
  description = "Name of the instance."
  type        = string
}

variable "prefix" {
  description = "An optional prefix used to generate the primary instance name."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "redis_version" {
  description = "The instance version to create. Defaults to the latest supported version."
  type        = string
  default     = null
  nullable    = true
}

variable "region" {
  description = "Region the instance will sit in."
  type        = string
}

variable "tier" {
  description = "The tier of the Redis instance. Defaults to 'BASIC'."
  type        = string
  default     = "BASIC"
  validation {
    condition     = contains(["BASIC", "STANDARD_HA"], var.tier)
    error_message = "tier must be either 'BASIC' or 'STANDARD_HA'."
  }
}

variable "zone" {
  description = "Compute zone the instance will sit in"
  type        = string
}
