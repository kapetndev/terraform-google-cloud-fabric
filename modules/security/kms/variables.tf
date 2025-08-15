variable "create_key_ring" {
  description = ""
  type        = bool
  default     = true
}

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

variable "location" {
  description = ""
  type        = string
}

variable "key_ring_name" {
  description = ""
  type        = string
}

variable "keys" {
  description = ""
  type = map(object({
    destroy_scheduled_duration    = optional(string)
    labels                        = optional(map(string))
    purpose                       = optional(string, "ENCRYPT_DECRYPT")
    rotation_period               = optional(string, "7776000s") # 90 days
    skip_initial_version_creation = optional(bool, false)

    version_template = optional(object({
      algorithm        = string
      protection_level = string
    }))

    # IAM bindings and memberships. These mirror the IAM variables used for the key ring.
    iam = optional(map(set(string)), {})
    iam_bindings = optional(map(object({
      members = set(string)
      role    = string
      condition = optional(object({
        description = optional(string)
        expression  = string
        title       = string
      }))
    })), {})

    iam_members = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        description = optional(string)
        expression  = string
        title       = string
      }))
    })), {})
  }))
  default  = {}
  nullable = false
}

variable "prefix" {
  description = "An optional prefix applied to the service account name."
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
