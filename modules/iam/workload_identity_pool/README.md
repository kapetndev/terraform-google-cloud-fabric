# workload\_identity\_pool

Terraform module to create and manage Google Cloud Platform workload identity
pools.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "github_workload_identity_pool" {
  source       = "git::https://github.com/kapetndev/terraform-google-iam.git//modules/workload_identity_pool?ref=v0.1.0"
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

## Examples

- [workload-identity](../../examples/workload-identity) - Create a federated
  workload identity pool.

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.71.0 |

## Resources

| Name | Type |
|------|------|
| [`google_iam_workload_identity_pool.pool`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool) | resource |
| [`google_iam_workload_identity_pool_provider.identity_providers[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/iam_workload_identity_pool_provider) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The ID to use for the pool, which becomes the final component of the resource name. This value should be 4-32 characters, and may contain the characters `[a-z0-9-]` | `string` | | yes |
| `description` | A description of the pool. Cannot exceed 256 characters | `string` | `null` | no |
| `disabled` | Whether the pool is disabled. You cannot use a disabled pool to exchange tokens, or use existing tokens to access resources. If the pool is re-enabled, existing tokens grant access again | `bool` | `false` | no |
| `display_name` | A display name for the pool. Cannot exceed 32 characters. If not provided the value of `name` is used | `string` | `null` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
| `identity_providers` | Identity providers to use for the pool | `map(object{...})` | `{}` | no |
| `identity_providers.[*].attribute_condition` | A common expression language expression, in plain text, to restrict what otherwise valid authentication credentials issued by the provider should not be accepted. The expression must output a boolean representing whether to allow the federation | `string` | `null` | no |
| `identity_providers.[*].attribute_mapping` | Maps attributes from authentication credentials issued by an external identity provider to Google Cloud attributes | `map(string)` | `null` | no |
| `identity_providers.[*].description` | A description of the provider. Cannot exceed 256 characters | `string` | `null` | no |
| `identity_providers.[*].disabled` | Whether the provider is disabled. You cannot use a disabled provider to exchange tokens. However existing tokens still grant access | `bool` | `false` | no |
| `identity_providers.[*].display_name` | A display name for the provider. Cannot exceed 256 characters. If not provided the value of provider key is used | `string` | `null` | no |
| `identity_providers.[*].aws` | An Amazon Web Services identity provider. Only one of `aws` or `oidc` may be specified | `object` | `null` | no |
| `identity_providers.[*].aws.account_id` | The AWS account ID | `string` | | yes |
| `identity_providers.[*].oidc` | An OpenId Connect 1.0 identity provider. Only one of `aws` or `oidc` may be specified | `object` | `null` | no |
| `identity_providers.[*].oidc.issuer_uri` | The OIDC issuer URI | `string` | | yes |
| `identity_providers.[*].oidc.allowed_audiences` | Acceptable values for the `aud` field (audience) in the OIDC token | `set(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `workload_identity_pool_id` | The ID of the pool |
| `identity_provider_ids` | The IDs of the identity providers |
