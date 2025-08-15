# Google Cloud Platform Project

Terraform module to create and manage a Google Cloud Platform project.

## Usage

See the [examples](examples) directory for working examples for reference:

```hcl
module "my_project" {
  source = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/platform/project?ref=v0.1.0"
  name   = "my-project"
  parent = "organizations/1234567890" # or "folders/1234567890"
}
```

## Examples

- [minimal-project](examples/minimal-project) - Create a project with the
  minimal configuration.
- [project-and-services](examples/project-and-services) - Create a project with
  additional configuration to manage services and IAM.

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_org_policy_policy.policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | resource |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project) | resource |
| [google_project_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_binding) | resource |
| [google_project_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.services](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_tags_tag_binding.binding](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |
| [random_id.project_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The project name. An ID suffix will be added to the name to ensure uniqueness. | `string` | n/a | yes |
| <a name="input_parent"></a> [parent](#input\_parent) | The parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | n/a | yes |
| <a name="input_auto_create_network"></a> [auto\_create\_network](#input\_auto\_create\_network) | Whether to create the default network for the project. | `bool` | `false` | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The alphanumeric billing account ID. | `string` | `null` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | The authoritative name of the project. Used instead of `name` variable. | `string` | `null` | no |
| <a name="input_disable_dependent_services"></a> [disable\_dependent\_services](#input\_disable\_dependent\_services) | Whether to disable dependent services when disabling a service. | `bool` | `false` | no |
| <a name="input_disable_on_destroy"></a> [disable\_on\_destroy](#input\_disable\_on\_destroy) | Whether to disable the service when the resource is destroyed. | `bool` | `true` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Organization policies scoped to this project. | <pre>map(object({<br/>    dry_run             = optional(bool, false)<br/>    inherit_from_parent = optional(bool) # for list policies only.<br/>    reset               = optional(bool)<br/>    rules = optional(list(object({<br/>      allow = optional(object({<br/>        all    = optional(bool)<br/>        values = optional(list(string))<br/>      }))<br/>      deny = optional(object({<br/>        all    = optional(bool)<br/>        values = optional(list(string))<br/>      }))<br/>      enforce = optional(bool) # for boolean policies only.<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        location    = optional(string)<br/>        title       = optional(string)<br/>      }))<br/>      parameters = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix used to generate the project id. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project. If it is not provided the name of the project is used followed by a random suffix. | `string` | `null` | no |
| <a name="input_services"></a> [services](#input\_services) | A list of services to enable in the project. | `set(string)` | `[]` | no |
| <a name="input_tag_bindings"></a> [tag\_bindings](#input\_tag\_bindings) | Tag bindings for this project, in {KEY => TAG} value id format. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The project ID. |
| <a name="output_project_number"></a> [project\_number](#output\_project\_number) | The numeric identifier of the project. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
