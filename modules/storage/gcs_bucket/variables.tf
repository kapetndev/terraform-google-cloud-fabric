variable "autoclass" {
  description = <<EOF
Autoclass configuration for the bucket. When set, GCS automatically transitions
objects to colder storage classes based on access patterns. Mutually exclusive
with a fixed `storage_class` of NEARLINE, COLDLINE, or ARCHIVE.

(Optional) terminal_storage_class - The storage class that objects transition to if they are not read for a long period. Must be one of `NEARLINE` or `ARCHIVE`. Defaults to `NEARLINE`.
EOF
  type = object({
    terminal_storage_class = optional(string, "NEARLINE")
  })
  default = null
  validation {
    condition     = var.autoclass == null || var.autoclass.terminal_storage_class == null || contains(["NEARLINE", "ARCHIVE"], var.autoclass.terminal_storage_class)
    error_message = "autoclass: `terminal_storage_class` must be one of `NEARLINE` or `ARCHIVE`."
  }
}

variable "cors" {
  description = <<EOF
CORS configuration for the bucket. Required when the bucket serves assets
accessed from a different origin (e.g. a frontend application).

(Required) methods - HTTP methods to allow, e.g. ["GET", "HEAD"].
(Required) origins - Origins to allow, e.g. ["https://example.com"].
(Required) response_header_values - HTTP headers the browser can expose to the requesting origin.
(Optional) max_age_seconds - How long the browser can cache a preflight response, in seconds. Defaults to 3600.
EOF
  type = object({
    max_age_seconds        = optional(number, 3600)
    methods                = list(string)
    origins                = list(string)
    response_header_values = list(string)
  })
  default = null
}

variable "default_event_based_hold" {
  description = "Enable default event-based hold for new objects in the bucket. When enabled, objects cannot be deleted or replaced until the hold is explicitly released. Cannot be used with `hierarchical_namespace`."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_object_retention" {
  description = "Enable object retention for the bucket. When enabled, individual objects can be assigned a retention period during which they cannot be deleted or overwritten. Requires uniform bucket-level access."
  type        = bool
  default     = false
  nullable    = false
}

variable "force_destroy" {
  description = "If true, allows the bucket to be destroyed even if it contains objects. This is a dangerous operation and should be used with caution. Defaults to false."
  type        = bool
  default     = false
  nullable    = false
}

variable "group_iam" {
  description = "Authoritative IAM binding for organisation groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "hierarchical_namespace" {
  description = "Enable hierarchical namespace for the bucket, which organises objects into a directory structure. Automatically enables uniform bucket-level access. Cannot be used with `default_event_based_hold`."
  type        = bool
  default     = false
  nullable    = false
}

variable "iam" {
  description = "Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "iam_bindings" {
  description = "Authoritative IAM bindings with conditions in `{ROLE => {members = [MEMBERS], condition = {}}}` format. Roles cannot appear in both this variable and `iam`. Keys are the IAM role."
  type = map(object({
    members = set(string)
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
  nullable    = false
}

variable "lifecycle_rules" {
  description = <<EOF
Lifecycle rules for the bucket. Each rule defines an action to take when an
object matches the given condition.

(Required) action_type - The action to take. Must be one of `Delete`, `SetStorageClass`, or `AbortIncompleteMultipartUpload`.

(Optional) action - The action to take when the condition is met.
(Required) action.storage_class - The target storage class for `SetStorageClass` actions.

(Optional) condition - The condition under which the action will be taken. If not specified, the action will be taken on all objects in the bucket.
(Optional) condition.age - Age of the object in days.
(Optional) condition.created_before - Objects created before this date (YYYY-MM-DD).
(Optional) condition.custom_time_before - Objects whose custom time is before this date (YYYY-MM-DD).
(Optional) condition.days_since_custom_time - Days since the object's custom time.
(Optional) condition.days_since_noncurrent_time - Days since the object became noncurrent.
(Optional) condition.matches_prefix - List of object name prefixes to match.
(Optional) condition.matches_storage_class - List of storage classes to match.
(Optional) condition.matches_suffix - List of object name suffixes to match.
(Optional) condition.noncurrent_time_before - Noncurrent objects before this date (YYYY-MM-DD).
(Optional) condition.num_newer_versions - Number of newer versions required before this version matches.
(Optional) condition.with_state - Match objects by their live state. One of `LIVE`, `ARCHIVED`, or `ANY`.
EOF
  type = set(object({
    action_type = string
    action = optional(object({
      storage_class = string
    }))
    condition = optional(object({
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
    }))
  }))
  default  = []
  nullable = false
}

variable "location" {
  description = "The GCS location for the bucket. Can be a region (e.g. `europe-west2`), a dual-region (e.g. `EUR4`), or a multi-region (e.g. `EU`). See https://cloud.google.com/storage/docs/locations."
  type        = string
  nullable    = false
}

variable "logging_config" {
  description = <<EOF
Access log delivery configuration. Logs are written as objects to the specified
bucket.

(Required) log_bucket - The name of the bucket to which access logs are delivered.
(Optional) log_object_prefix - Prefix for log object names. Defaults to the bucket name.
EOF
  type = object({
    log_bucket        = string
    log_object_prefix = optional(string)
  })
  default = null
}

variable "name" {
  description = "Name of the bucket. Must be globally unique across all of GCS."
  type        = string
  nullable    = false
}

variable "prefix" {
  description = "An optional prefix prepended to `name` to form the full bucket name. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If not provided, the provider project is used."
  type        = string
  default     = null
}

variable "public_access_prevention" {
  description = "Public access prevention policy for the bucket. `enforced` blocks all public access regardless of IAM policies. `inherited` defers to the organisation policy. Defaults to `inherited`."
  type        = string
  default     = "inherited"
  nullable    = false
  validation {
    condition     = contains(["inherited", "enforced"], var.public_access_prevention)
    error_message = "`public_access_prevention` must be one of `inherited` or `enforced`."
  }
}

variable "requester_pays" {
  description = "When enabled, the requester of each operation is billed for network and operation costs rather than the bucket owner. Defaults to false."
  type        = bool
  default     = false
  nullable    = false
}

variable "retention_policy" {
  description = <<EOF
Bucket-level retention policy. Objects cannot be deleted or overwritten until
their retention period has elapsed.

(Required) retention_period - Retention period in seconds.
(Optional) is_locked - If true, the retention policy cannot be reduced or removed. Defaults to false. Warning: locking a retention policy is irreversible.
EOF
  type = object({
    retention_period = number
    is_locked        = optional(bool, false)
  })
  default = null
}

variable "storage_class" {
  description = "Default storage class for objects in the bucket. Applies to new objects unless overridden by a lifecycle rule or autoclass. Must be one of `STANDARD`, `MULTI_REGIONAL`, `REGIONAL`, `NEARLINE`, `COLDLINE`, or `ARCHIVE`. Defaults to `STANDARD`."
  type        = string
  default     = "STANDARD"
  nullable    = false
  validation {
    condition     = contains(["STANDARD", "MULTI_REGIONAL", "REGIONAL", "NEARLINE", "COLDLINE", "ARCHIVE"], var.storage_class)
    error_message = "`storage_class` must be one of `STANDARD`, `MULTI_REGIONAL`, `REGIONAL`, `NEARLINE`, `COLDLINE`, or `ARCHIVE`."
  }
}

variable "uniform_bucket_level_access" {
  description = "Enables uniform bucket-level access, which disables object-level ACLs and enforces IAM-only access control. Defaults to true. Automatically enabled when `hierarchical_namespace` is true."
  type        = bool
  default     = true
  nullable    = false
}

variable "versioning" {
  description = "Enable object versioning for the bucket. When enabled, overwriting or deleting an object creates a new version rather than permanently removing data. Defaults to true."
  type        = bool
  default     = true
  nullable    = false
}

variable "website" {
  description = <<EOF
Static website configuration. When set, the bucket serves its contents as a website.

(Optional) main_page_suffix - The object to serve when a directory is requested, e.g. `index.html`.
(Optional) not_found_page - The object to serve for 404 responses, e.g. `404.html`.
EOF
  type = object({
    main_page_suffix = optional(string)
    not_found_page   = optional(string)
  })
  default = null
}
