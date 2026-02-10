# IAM Workload Identity Pool

Terraform module to create and manage IAM workload identity pools that enable
external identity providers (AWS or OIDC) to authenticate with GCP
resources. The module configures identity providers with attribute mapping and
conditional access controls, allowing workloads running outside GCP to assume
service account identities without requiring long-lived credentials.

## Usage

```hcl
module "github_workload_identity_pool" {
  source       = "github.com/kapetndev/terraform-google-cloud-fabric//modules/iam/workload_identity_pool?ref=v0.1.0"
  description  = "Identity pool for GitHub"
  display_name = "GitHub"
  name         = "github-pool"

  identity_providers = {
    {
      attribute_condition = "assertion.repository_owner = ${var.github_organization}"
      attribute_mapping = {
        "google.subject"             = "assertion.sub",
        "attribute.actor"            = "assertion.actor",
        "attribute.repository_owner" = "assertion.repository_owner",
      }
      description  = "GitHub identity provider"
      display_name = "GitHub"
      name         = "github"
      oidc = {
        issuer_uri = "https://token.actions.githubusercontent.com"
      }
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |

## Resources

| Name | Type |
|------|------|
| [google_iam_workload_identity_pool.pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [google_iam_workload_identity_pool_provider.identity_providers](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Fully qualified, authoritative display name of the pool. Cannot exceed 32 characters. | `string` | n/a | yes |
| <a name="input_pool_id"></a> [pool\_id](#input\_pool\_id) | The ID to use for the pool, which becomes the final component of the resource name. This value should be 4-32 characters, and may contain the characters `[a-z0-9-]`. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | A description of the pool. Cannot exceed 256 characters. | `string` | `null` | no |
| <a name="input_disabled"></a> [disabled](#input\_disabled) | Whether the pool is disabled. You cannot use a disabled pool to exchange tokens, or use existing tokens to access resources. If the pool is re-enabled, existing tokens grant access again. | `bool` | `false` | no |
| <a name="input_identity_providers"></a> [identity\_providers](#input\_identity\_providers) | Identity providers to use for the pool.<br/><br/>(Optional) attribute\_condition -  A common expression language expression, in plain text, to restrict what otherwise valid authentication credentials issued by the provider should not be accepted. The expression must output a boolean representing whether to allow the federation.<br/>(Optional) attribute\_mapping - Maps attributes from authentication credentials issued by an external identity provider to Google Cloud attributes.<br/>(Optional) description - A description of the provider. Cannot exceed 256 characters.<br/>(Optional) disabled - Whether the provider is disabled. You cannot use a disabled provider to exchange tokens. However existing tokens still grant access.<br/>(Optional) display\_name - A display name for the provider. Cannot exceed 256 characters. If not provided the value of provider key is used.<br/><br/>(Optional) aws - An Amazon Web Services identity provider. Only one of `aws` or `oidc` may be specified.<br/>(Optional) aws.account\_id - The AWS account ID.<br/><br/>(Optional) oidc - An OpenID Connect 1.0 identity provider. Only one of `aws` or `oidc` may be specified.<br/>(Optional) oidc.allowed\_audiences - Acceptable values for the `aud` field (audience) in the OIDC token.<br/>(Optional) oidc.issuer\_uri - The OIDC issuer URI. | <pre>map(object({<br/>    attribute_condition = optional(string)<br/>    attribute_mapping   = optional(map(string))<br/>    description         = optional(string)<br/>    disabled            = optional(bool, false)<br/>    display_name        = optional(string)<br/>    aws = optional(object({<br/>      account_id = string<br/>    }))<br/>    oidc = optional(object({<br/>      allowed_audiences = optional(set(string))<br/>      issuer_uri        = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project in which to create the service account. Defaults to the provider project if not set. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_identity_providers"></a> [identity\_providers](#output\_identity\_providers) | Map of identity provider IDs keyed by provider name, matching the keys supplied in `var.identity_providers`. Use these IDs when constructing the full provider resource name for use in attribute conditions or external identity configurations. |
| <a name="output_pool_id"></a> [pool\_id](#output\_pool\_id) | The ID of the Workload Identity Pool. Use this when constructing the Workload Identity member string: `principalSet://iam.googleapis.com/{projects/PROJECT_ID/locations/global/workloadIdentityPools/POOL_ID}/attribute.ATTRIBUTE/VALUE`. |
| <a name="output_pool_name"></a> [pool\_name](#output\_pool\_name) | The ID of the Workload Identity Pool. Use this when constructing the Workload Identity member string: `principalSet://iam.googleapis.com/{projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID}/attribute.ATTRIBUTE/VALUE`. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
