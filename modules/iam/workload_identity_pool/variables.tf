variable "description" {
  description = "A description of the pool. Cannot exceed 256 characters."
  type        = string
  default     = null
}

variable "disabled" {
  description = "Whether the pool is disabled. You cannot use a disabled pool to exchange tokens, or use existing tokens to access resources. If the pool is re-enabled, existing tokens grant access again."
  type        = bool
  default     = false
}

variable "display_name" {
  description = "A display name for the pool. Cannot exceed 32 characters. If not provided the value of `name` is used."
  type        = string
  default     = null
}

variable "name" {
  description = "The ID to use for the pool, which becomes the final component of the resource name. This value should be 4-32 characters, and may contain the characters `[a-z0-9-]`."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "identity_providers" {
  description = <<EOF
Identity providers to use for the pool.

(Optional) attribute_condition -  A common expression language expression, in plain text, to restrict what otherwise valid authentication credentials issued by the provider should not be accepted. The expression must output a boolean representing whether to allow the federation.
(Optional) attribute_mapping - Maps attributes from authentication credentials issued by an external identity provider to Google Cloud attributes.
(Optional) description - A description of the provider. Cannot exceed 256 characters.
(Optional) disabled - Whether the provider is disabled. You cannot use a disabled provider to exchange tokens. However existing tokens still grant access.
(Optional) display_name - A display name for the provider. Cannot exceed 256 characters. If not provided the value of provider key is used.
(Optional) aws - An Amazon Web Services identity provider. Only one of `aws` or `oidc` may be specified.
(Optional) aws.account_id - The AWS account ID.
(Optional) oidc - An OpenID Connect 1.0 identity provider. Only one of `aws` or `oidc` may be specified.
(Optional) oidc.allowed_audiences - Acceptable values for the `aud` field (audience) in the OIDC token.
(Optional) oidc.issuer_uri - The OIDC issuer URI.
EOF
  type = map(object({
    attribute_condition = optional(string)
    attribute_mapping   = optional(map(string))
    description         = optional(string)
    disabled            = optional(bool, false)
    display_name        = optional(string)
    aws = optional(object({
      account_id = string
    }))
    oidc = optional(object({
      allowed_audiences = optional(set(string))
      issuer_uri        = string
    }))
  }))
  default = {}
  validation {
    condition     = length(var.identity_providers) > 0
    error_message = "At least one identity provider must be specified"
  }
  validation {
    condition = length([
      for p in var.identity_providers : p if p.aws != null || p.oidc != null
    ]) == length(var.identity_providers)
    error_message = "One of aws or oidc must be specified per provider"
  }
}
