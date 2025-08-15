# Google Cloud Platform Folder

Terraform module to create and manage GCP folders with IAM bindings and
organisation policies applied at the folder level. It mirrors the organisation
module's IAM binding capabilities, offering authoritative, keyed, and
non-authoritative modes alongside group-based assignments and conditional
access. Folder-scoped policies support the same boolean and list-based
constraints available at the organisation level.

## Usage

```hcl
module "engineerig_folder" {
  source       = "github.com/kapetndev/terraform-google-cloud-fabric//modules/platform/folder?ref=v0.1.0"
  display_name = "Engineering"
  parent       = "organizations/1234567890" # or "folders/1234567890"
}
```

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

## Resources

| Name | Type |
|------|------|
| [google_folder.folder](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder) | resource |
| [google_folder_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_folder_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_binding) | resource |
| [google_folder_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_member) | resource |
| [google_org_policy_policy.policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_display_name"></a> [display\_name](#input\_display\_name) | Arbitrary user-provided name for the folder. | `string` | n/a | yes |
| <a name="input_parent"></a> [parent](#input\_parent) | The parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format. | `string` | n/a | yes |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Organization policies scoped to this folder. | <pre>map(object({<br/>    dry_run             = optional(bool, false)<br/>    inherit_from_parent = optional(bool) # for list policies only.<br/>    reset               = optional(bool)<br/>    rules = optional(list(object({<br/>      allow = optional(object({<br/>        all    = optional(bool)<br/>        values = optional(list(string))<br/>      }))<br/>      deny = optional(object({<br/>        all    = optional(bool)<br/>        values = optional(list(string))<br/>      }))<br/>      enforce = optional(bool) # for boolean policies only.<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        location    = optional(string)<br/>        title       = optional(string)<br/>      }))<br/>      parameters = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_folder_id"></a> [folder\_id](#output\_folder\_id) | The folder ID. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
