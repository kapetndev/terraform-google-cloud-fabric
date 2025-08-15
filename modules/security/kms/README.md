# Google Cloud KMS Key Ring and Crypto Key Module

## Usage

See the [examples](examples) directory for working examples for reference:

```hcl
module "my_kms_keys" {
  source        = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/security/kms?ref=v0.1.0"
  key_ring_name = "my-key-ring"
  location      = "europe-west2"

  keys = {
    "my-key" = {
      version_template = {
        algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
        protection_level = "SOFTWARE"
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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.83.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.83.0 |

## Resources

| Name | Type |
|------|------|
| [google_kms_crypto_key.keys](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key) | resource |
| [google_kms_crypto_key_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_binding) | resource |
| [google_kms_crypto_key_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_binding) | resource |
| [google_kms_crypto_key_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_crypto_key_iam_member) | resource |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring) | resource |
| [google_kms_key_ring_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_iam_binding) | resource |
| [google_kms_key_ring_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_iam_binding) | resource |
| [google_kms_key_ring_iam_member.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/kms_key_ring_iam_member) | resource |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_key_ring_name"></a> [key\_ring\_name](#input\_key\_ring\_name) | n/a | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_create_key_ring"></a> [create\_key\_ring](#input\_create\_key\_ring) | n/a | `bool` | `true` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | n/a | <pre>map(object({<br/>    destroy_scheduled_duration    = optional(string)<br/>    labels                        = optional(map(string))<br/>    purpose                       = optional(string, "ENCRYPT_DECRYPT")<br/>    rotation_period               = optional(string, "7776000s") # 90 days<br/>    skip_initial_version_creation = optional(bool, false)<br/><br/>    version_template = optional(object({<br/>      algorithm        = string<br/>      protection_level = string<br/>    }))<br/><br/>    # IAM bindings and memberships. These mirror the IAM variables used for the key ring.<br/>    iam = optional(map(set(string)), {})<br/>    iam_bindings = optional(map(object({<br/>      members = set(string)<br/>      role    = string<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        title       = string<br/>      }))<br/>    })), {})<br/><br/>    iam_members = optional(map(object({<br/>      member = string<br/>      role   = string<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        title       = string<br/>      }))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix applied to the service account name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |

## Outputs

No outputs.
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
