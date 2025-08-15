variable "auto_create_network" {
  description = "Whether to create the default network for the project."
  type        = bool
  default     = false
}

variable "billing_account" {
  description = "The alphanumeric billing account ID."
  type        = string
  default     = null
}

variable "descriptive_name" {
  description = "The authoritative name of the project. Used instead of `name` variable."
  type        = string
  default     = null
}

variable "disable_dependent_services" {
  description = "Whether to disable dependent services when disabling a service."
  type        = bool
  default     = false
}

variable "disable_on_destroy" {
  description = "Whether to disable the service when the resource is destroyed."
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

variable "name" {
  description = "The project name. An ID suffix will be added to the name to ensure uniqueness."
  type        = string
}

variable "parent" {
  description = "The parent folder or organization in 'folders/folder_id' or 'organizations/org_id' format."
  type        = string
  validation {
    condition     = can(regex("(organizations|folders)/[0-9]+", var.parent))
    error_message = "Parent must be of the form folders/folder_id or organizations/organization_id."
  }
}

variable "policies" {
  description = "Organization policies scoped to this project."
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
  description = "An optional prefix used to generate the project id."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}

variable "project_id" {
  description = "The ID of the project. If it is not provided the name of the project is used followed by a random suffix."
  type        = string
  default     = null
}

variable "services" {
  description = "A list of services to enable in the project."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "tag_bindings" {
  description = "Tag bindings for this project, in {KEY => TAG} value id format."
  type        = map(string)
  default     = {}
  nullable    = false
}
