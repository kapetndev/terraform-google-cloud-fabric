variable "auto_create_network" {
  description = "Whether to create the default VPC network for the project. Defaults to false — the default network is a legacy construct that should be avoided in new projects."
  type        = bool
  default     = false
  nullable    = false
}

variable "billing_account" {
  description = "The alphanumeric billing account ID to associate with the project. Required to enable paid APIs and services."
  type        = string
  default     = null
}

variable "disable_dependent_services" {
  description = "When disabling a service, also disable any services that depend on it. Defaults to false."
  type        = bool
  default     = false
  nullable    = false
}

variable "disable_on_destroy" {
  description = "Disable services when they are removed from the `services` set. Defaults to true. Set to false if services are managed outside this module or if disabling them on removal would break existing workloads."
  type        = bool
  default     = true
  nullable    = false
}

variable "display_name" {
  description = "Fully qualified, authoritative display name of the project. When set, `name` and `project_id` are mutually exclusive. Set one or the other, not both."
  type        = string
  default     = null
}

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

variable "name" {
  description = "The project name. Used as a prefix when generating the project ID unless `project_id` is explicitly set."
  type        = string
  default     = ""
  nullable    = false
}

variable "parent" {
  description = "The parent folder or organisation in `folders/FOLDER_ID` or `organizations/ORG_ID` format."
  type        = string
  nullable    = false
  validation {
    condition     = can(regex("(organizations|folders)/[0-9]+", var.parent))
    error_message = "`parent` must be in the form `folders/FOLDER_ID` or `organizations/ORG_ID`."
  }
}

variable "policies" {
  description = "Organisation policies scoped to this project, keyed by constraint name (e.g. `constraints/compute.requireOsLogin`)."
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

variable "prefix" {
  description = "An optional prefix prepended to `name` when generating the project ID. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "project_id" {
  description = "An explicit project ID. When set, the module uses this value directly rather than generating one from `name`. Must be unique within GCP."
  type        = string
  default     = null
}

variable "services" {
  description = "Set of GCP API service names to enable on the project, e.g. `[\"storage.googleapis.com\", \"container.googleapis.com\"]`."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "tag_bindings" {
  description = "Tag bindings to attach to the project in `{TAG_KEY => TAG_VALUE_ID}` format, where TAG_VALUE_ID is the full tag value resource ID."
  type        = map(string)
  default     = {}
  nullable    = false
}
