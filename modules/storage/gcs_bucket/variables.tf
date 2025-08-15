variable "autoclass" {
  description = "Enable autoclass for the bucket."
  type = object({
    enabled                = bool
    terminal_storage_class = optional(string)
  })
  default  = null
  nullable = true
  validation {
    condition     = var.autoclass == null || var.autoclass.terminal_storage_class == null || contains(["NEARLINE", "ARCHIVE"], var.autoclass.terminal_storage_class)
    error_message = "Terminal storage class for autoclass must be either NEARLINE or ARCHIVE."
  }
}

variable "cors" {
  description = "CORS configuration for the bucket."
  type = object({
    max_age_seconds         = optional(number, 3600)
    methods                 = list(string)
    origins                 = list(string)
    response_headers_values = list(string)
  })
  default = null
}

variable "default_event_based_hold" {
  description = "Enable default event-based hold for the bucket."
  type        = bool
  default     = false
}

variable "enable_object_retention" {
  description = "Enable object retention for the bucket."
  type        = bool
  default     = false
}

variable "encryption_key_name" {
  description = "The full path to the encryption key used for to encrypt objects inserted into the bucket."
  type        = string
  default     = null
}

variable "force_destroy" {
  description = "If true, allows the bucket to be destroyed even if it contains objects. This is a dangerous operation and should be used with caution."
  type        = bool
  default     = false
}

variable "group_iam" {
  description = "Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "hierarchical_namespace" {
  description = "Enable hierarchical namespace for the bucket. Also enables uniform bucket-level access."
  type        = bool
  default     = false
}

variable "iam" {
  description = "Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "iam_bindings" {
  description = "Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary."
  type = map(object({
    members = set(string)
    role    = string
    condition = optional(object({
      description = optional(string)
      expression  = string
      title       = string
    }))
  }))
  default  = {}
  nullable = false
}

variable "iam_members" {
  description = "Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary."
  type = map(object({
    member = string
    role   = string
    condition = optional(object({
      description = optional(string)
      expression  = string
      title       = string
    }))
  }))
  default  = {}
  nullable = false
}

variable "labels" {
  description = "A map of user defined key/value label pairs to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket."
  type = set(object({
    action_type = string
    action = object({
      storage_class = string
    })
    condition = object({
      age                                     = optional(number)
      created_before                          = optional(string)
      custom_time_before                      = optional(string)
      days_since_custom_time                  = optional(number)
      days_since_noncurrent_time              = optional(number)
      matches_prefix                          = optional(list(string))
      matches_storage_class                   = optional(list(string))
      matches_suffix                          = optional(list(string))
      noncurrent_time_before                  = optional(string)
      num_newer_versions                      = optional(number)
      send_age_if_zero                        = optional(bool)
      send_days_since_custom_time_if_zero     = optional(bool)
      send_days_since_noncurrent_time_if_zero = optional(bool)
      send_num_newer_versions_if_zero         = optional(bool)
      with_state                              = optional(string)
    })
  }))
  default = []
}

variable "location" {
  description = "Compute zone or region the bucket will sit in."
  type        = string
}

variable "logging_config" {
  description = "Logging configuration for the bucket."
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string)
  })
  default = null
}

variable "name" {
  description = "Name of the bucket."
  type        = string
}

variable "prefix" {
  description = "An optional prefix applied to the bucket name."
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

variable "public_access_prevention" {
  description = "Public access prevention for the bucket."
  type        = string
  default     = "inherited"
  validation {
    condition     = contains(["inherited", "enforced"], var.public_access_prevention)
    error_message = "Public access prevention must be one of 'inherited', or 'enforced'."
  }
}

variable "requester_pays" {
  description = "Enable requester pays for the bucket."
  type        = bool
  default     = false
}

variable "retention_policy" {
  description = "Retention policy for the bucket."
  type = object({
    retention_period = number
    is_locked        = optional(bool)
  })
  default = null
}

variable "storage_class" {
  description = "Storage class for the bucket."
  type        = string
  default     = "STANDARD"
  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "Storage class must be one of STANDARD, MULTI_REGIONAL, REGIONAL, NEARLINE, COLDLINE, or ARCHIVE."
  }
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access for the bucket."
  type        = bool
  default     = false
}

variable "website" {
  description = "Static website configuration for the bucket."
  type = object({
    main_page_suffix = optional(string)
    not_found_page   = optional(string)
  })
  default = null
}

variable "versioning" {
  description = "Enable versioning for the bucket."
  type        = bool
  default     = false
}
