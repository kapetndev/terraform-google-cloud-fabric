# Google Cloud Platform Organization

Terraform module to manage IAM bindings at the organisation level, supporting
both authoritative and non-authoritative modes. Role assignments can be made to
groups with conditional access controls.

The module also handles organisation policies, accommodating boolean and
list-based constraints whilst providing dry-run testing capabilities and parent
inheritance options.

## Usage

```hcl
module "organization_policies" {
  source          = "github.com/kapetndev/terraform-google-cloud-fabric//modules/platform/organization?ref=v0.1.0"
  organization_id = "organizations/1234567890" # or "folders/1234567890"
  
  policies = {
    "compute.disableSerialPortAccess" = {
      rules = [
        {
          allow = {
            all = true
          }
        }
      ]
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
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |

## Resources

| Name | Type |
|------|------|
| [google_org_policy_policy.policies](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/org_policy_policy) | resource |
| [google_organization_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_binding) | resource |
| [google_organization_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_binding) | resource |
| [google_organization_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | The parent organization 'organizations/org\_id' format. | `string` | n/a | yes |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_policies"></a> [policies](#input\_policies) | Organization policies. | <pre>map(object({<br/>    dry_run             = optional(bool, false)<br/>    inherit_from_parent = optional(bool) # for list policies only.<br/>    reset               = optional(bool)<br/>    rules = optional(list(object({<br/>      allow = optional(object({<br/>        all    = optional(bool)<br/>        values = optional(list(string))<br/>      }))<br/>      deny = optional(object({<br/>        all    = optional(bool)<br/>        values = optional(list(string))<br/>      }))<br/>      enforce = optional(bool) # for boolean policies only.<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        location    = optional(string)<br/>        title       = optional(string)<br/>      }))<br/>      parameters = optional(string)<br/>    })), [])<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
