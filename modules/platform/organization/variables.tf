variable "group_iam" {
  description = "Authoritative IAM binding for organisation groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable."
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

variable "organization_id" {
  description = "The organisation ID in `organizations/ORG_ID` format."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("^organizations/[0-9]+$", var.organization_id))
    error_message = "organization_id: must be in the form `organizations/ORG_ID`."
  }
}

variable "policies" {
  description = "Organisation policies scoped to this organisation, keyed by constraint name (e.g. `constraints/compute.requireOsLogin`)."
  type = map(object({
    dry_run             = optional(bool, false)
    inherit_from_parent = optional(bool) # for list policies only.
    reset               = optional(bool)
    rules = optional(list(object({
      allow = optional(object({
        all    = optional(bool)
        values = optional(list(string))
      }))
      deny = optional(object({
        all    = optional(bool)
        values = optional(list(string))
      }))
      enforce = optional(bool) # for boolean policies only.
      condition = optional(object({
        description = optional(string)
        expression  = string
        location    = optional(string)
        title       = optional(string)
      }))
      parameters = optional(string)
    })), [])
  }))
  default  = {}
  nullable = false
}
