variable "create_key_ring" {
  description = "When true, the module creates the key ring. When false, the module looks up an existing key ring by `key_ring_name` and `location`. Defaults to true. Note: key rings cannot be deleted from GCP — destroying a Terraform-managed key ring removes it from state only."
  type        = bool
  default     = true
  nullable    = false
}

variable "group_iam" {
  description = "Authoritative IAM binding for organisation groups on the key ring, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "iam" {
  description = "Authoritative IAM bindings on the key ring in `{ROLE => [MEMBERS]}` format."
  type        = map(set(string))
  default     = {}
  nullable    = false
}

variable "iam_bindings" {
  description = "Authoritative IAM bindings with conditions on the key ring in `{ROLE => {members = [MEMBERS], condition = {}}}` format. Roles cannot appear in both this variable and `iam`. Keys are the IAM role."
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
  description = "Non-authoritative IAM bindings on the key ring in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary."
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

variable "key_ring_name" {
  description = "The name of the KMS key ring. When `create_key_ring` is true this name is used for the new resource. When false it is used to look up an existing key ring."
  type        = string
}

variable "keys" {
  description = <<EOF
Map of KMS crypto keys to create within the key ring, keyed by key name.

(Optional) destroy_scheduled_duration - Duration after which a key version scheduled for destruction will be destroyed. Specified as a duration string e.g. `86400s`. Minimum 24 hours.
(Optional) labels - User-defined labels to assign to the key.
(Optional) purpose - The cryptographic purpose of the key. Must be one of `ENCRYPT_DECRYPT`, `ASYMMETRIC_SIGN`, `ASYMMETRIC_DECRYPT`, or `MAC`. Defaults to `ENCRYPT_DECRYPT`.
(Optional) rotation_period - Rotation period for symmetric keys, as a duration string e.g. `7776000s`. Defaults to 90 days. Not supported for asymmetric or MAC keys.
(Optional) skip_initial_version_creation - If true, no key version is created when the key is created. Defaults to false.

(Optional) version_template - Key version template controlling algorithm and protection level.
(Required) version_template.algorithm - The algorithm to use, e.g. `GOOGLE_SYMMETRIC_ENCRYPTION`, `RSA_SIGN_PSS_2048_SHA256`.
(Required) version_template.protection_level - The protection level. Must be one of `SOFTWARE` or `HSM`.

(Optional) iam - Authoritative IAM bindings on this key in `{ROLE => [MEMBERS]}` format.
(Optional) iam_bindings - Authoritative IAM bindings with conditions on this key in `{ROLE => {members, condition}}` format.
(Optional) iam_members - Non-authoritative IAM bindings on this key in `{KEY => {member, role, condition}}` format.
EOF
  type = map(object({
    destroy_scheduled_duration    = optional(string)
    labels                        = optional(map(string), {})
    purpose                       = optional(string, "ENCRYPT_DECRYPT")
    rotation_period               = optional(string, "7776000s") # 90 days in seconds
    skip_initial_version_creation = optional(bool, false)

    version_template = optional(object({
      algorithm        = string
      protection_level = string
    }))

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

variable "location" {
  description = "The GCP location for the key ring. Can be a region (e.g. `europe-west2`), a multi-region (e.g. `europe`), or `global`. Key rings are location-specific and cannot be moved."
  type        = string
}

variable "prefix" {
  description = "An optional prefix prepended to `key_ring_name`. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "prefix: cannot be an empty string. Use null to omit the prefix."
  }
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If not provided, the provider project is used."
  type        = string
  default     = null
}
