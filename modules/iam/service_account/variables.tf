variable "account_id" {
  description = "The account id that is used to generate the service account email address and a stable unique id. It is unique within a project, must be 6-30 characters long, and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])` to comply with RFC1035."
  type        = string
  nullable    = false
}

variable "description" {
  description = "A brief description of this resource."
  type        = string
  default     = null
}

variable "display_name" {
  description = "Fully qualified, authoritative display name of the service account."
  type        = string
  nullable    = false
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
  description = "Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary."
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

variable "project_id" {
  description = "The ID of the GCP project in which to create the service account. Defaults to the provider project if not set."
  type        = string
  default     = null
}
