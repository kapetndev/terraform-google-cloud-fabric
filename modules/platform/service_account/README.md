# service\_account

Terraform module to create and manage Google Cloud Platform service accounts.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "cloudsql_service_account" {
  source       = "git::https://github.com/kapetndev/terraform-google-iam.git//modules/service_account?ref=v0.1.0"
  display_name = "CloudSQL"
  name         = "cloudsql-sa"
}
```

## Examples

- [workload-identity](../../examples/workload-identity) - Create a service
  account for a federated workload identity pool.

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
| [`google_service_account.service_account`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service) | resource |
| [`google_service_account_iam_binding.authoritative[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam) | resource |
| [`google_service_account_iam_member.non_authoritative[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_service_account_iam) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The account id that is used to generate the service account email address and a stable unique id. It is unique within a project, must be 6-30 characters long, and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])` to comply with RFC1035 | `string` | | yes |
| `description` | A brief description of this resource | `string` | `null` | no |
| `display_name` | A display name for the service account. Can be updated without creating a new resource. If not provided the value of `name` is used | `string` | `null` | no |
| `group_iam` | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable | `map(set(string))` | `{}` | no |
| `iam` | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format | `map(set(string))` | `{}` | no |
| `iam_member` | Non-authoritative IAM bindings in `{ROLE = [MEMBERS]}` format. Can be used in combination with the `iam` variable. Typically this will be used for default service accounts or other Google managed resources | `map(set(string))` | `{}` | no |
| `prefix` | An optional prefix applied to the service account name | `string` | `null` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `service_account_email` | The email address of the service account |
