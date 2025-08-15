# IAM Service Account

Terraform module to create and manage Google Cloud Platform service accounts.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "cloudsql_service_account" {
  source       = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/iam/service_account?ref=v0.1.0"
  display_name = "CloudSQL"
  name         = "cloudsql-sa"
}
```

## Examples

- [workload-identity](../../examples/workload-identity) - Create a service
  account for a federated workload identity pool.

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.30.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.30.0 |

## Resources

| Name | Type |
|------|------|
| [google_service_account.service_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_binding) | resource |
| [google_service_account_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The account id that is used to generate the service account email address and a stable unique id. It is unique within a project, must be 6-30 characters long, and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])` to comply with RFC1035. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | A brief description of this resource. | `string` | `null` | no |
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | A display name for the service account. Can be updated without creating a new resource. If not provided the value of `name` is used. | `string` | `null` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix applied to the service account name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_account_email"></a> [service\_account\_email](#output\_service\_account\_email) | The email address of the service account. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
