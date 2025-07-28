variable "group_iam" {
  description = "Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "iam" {
  description = "Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "iam_members" {
  description = "Non-authoritative IAM bindings in `{ROLE = [MEMBERS]}` format. Can be used in combination with the `iam` variable. Typically this will be used for default service accounts or other Google managed resources."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "labels" {
  description = "A map of user defined key/value label pairs to assign to the bucket."
  type        = map(string)
  default     = {}
}

variable "location" {
  description = "Compute zone or region the bucket will sit in."
  type        = string
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

variable "autoclass" {
  description = "Enable autoclass for the bucket."
  type        = bool
  default     = false
}

variable "cors" {
  description = "CORS configuration for the bucket."
  type = object({
    max_age_seconds = number
    method          = list(string)
    origin          = list(string)
    response_header = list(string)
  })
  default = null
}

variable "lifecycle_rules" {
  description = "Lifecycle rules for the bucket."
  type = set(object({
    action_type = string
    action = object({
      storage_class = string
    })
    condition = object({
      age                   = optional(number)
      created_before        = optional(string)
      is_live               = optional(bool)
      matches_storage_class = optional(list(string))
      num_newer_versions    = optional(number)
    })
  }))
  default = []
}

variable "versioning" {
  description = "Enable versioning for the bucket."
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

variable "logging_config" {
  description = "Logging configuration for the bucket."
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string)
  })
}

variable "retention_policy" {
  description = "Retention policy for the bucket."
  type = object({
    retention_period = number
    is_locked        = optional(bool)
  })
  default = null
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access for the bucket."
  type        = bool
  default     = false
}

variable "storage_class" {
  description = "Storage class for the bucket."
  type        = string
  default     = "STANDARD"
}
