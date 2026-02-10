# KMS Key Ring and Crypto Key

Terraform module to create or reference existing KMS key rings and provisions
crypto keys for encryption and decryption with the following capabilities:

- Configurable rotation periods (defaulting to 90 days)
- Algorithm and protection level templates
- Scheduled destruction durations
- IAM bindings for key rings and individual crypto keys with per-key access
  policies

Key rings and crypto keys are protected from accidental deletion through
lifecycle rules, though scheduled key destruction will render encrypted data
irrecoverable.

## Usage

```hcl
module "my_kms_keys" {
  source        = "github.com/kapetndev/terraform-google-cloud-fabric//modules/security/kms?ref=v0.1.0"
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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |

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
| <a name="input_key_ring_name"></a> [key\_ring\_name](#input\_key\_ring\_name) | The name of the KMS key ring. When `create_key_ring` is true this name is used for the new resource. When false it is used to look up an existing key ring. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The GCP location for the key ring. Can be a region (e.g. `europe-west2`), a multi-region (e.g. `europe`), or `global`. Key rings are location-specific and cannot be moved. | `string` | n/a | yes |
| <a name="input_create_key_ring"></a> [create\_key\_ring](#input\_create\_key\_ring) | When true, the module creates the key ring. When false, the module looks up an existing key ring by `key_ring_name` and `location`. Defaults to true. Note: key rings cannot be deleted from GCP — destroying a Terraform-managed key ring removes it from state only. | `bool` | `true` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organisation groups on the key ring, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings on the key ring in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings with conditions on the key ring in `{ROLE => {members = [MEMBERS], condition = {}}}` format. Roles cannot appear in both this variable and `iam`. Keys are the IAM role. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings on the key ring in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_keys"></a> [keys](#input\_keys) | Map of KMS crypto keys to create within the key ring, keyed by key name.<br/><br/>(Optional) destroy\_scheduled\_duration - Duration after which a key version scheduled for destruction will be destroyed. Specified as a duration string e.g. `86400s`. Minimum 24 hours.<br/>(Optional) labels - User-defined labels to assign to the key.<br/>(Optional) purpose - The cryptographic purpose of the key. Must be one of `ENCRYPT_DECRYPT`, `ASYMMETRIC_SIGN`, `ASYMMETRIC_DECRYPT`, or `MAC`. Defaults to `ENCRYPT_DECRYPT`.<br/>(Optional) rotation\_period - Rotation period for symmetric keys, as a duration string e.g. `7776000s`. Defaults to 90 days. Not supported for asymmetric or MAC keys.<br/>(Optional) skip\_initial\_version\_creation - If true, no key version is created when the key is created. Defaults to false.<br/><br/>(Optional) version\_template - Key version template controlling algorithm and protection level.<br/>(Required) version\_template.algorithm - The algorithm to use, e.g. `GOOGLE_SYMMETRIC_ENCRYPTION`, `RSA_SIGN_PSS_2048_SHA256`.<br/>(Required) version\_template.protection\_level - The protection level. Must be one of `SOFTWARE` or `HSM`.<br/><br/>(Optional) iam - Authoritative IAM bindings on this key in `{ROLE => [MEMBERS]}` format.<br/>(Optional) iam\_bindings - Authoritative IAM bindings with conditions on this key in `{ROLE => {members, condition}}` format.<br/>(Optional) iam\_members - Non-authoritative IAM bindings on this key in `{KEY => {member, role, condition}}` format. | <pre>map(object({<br/>    destroy_scheduled_duration    = optional(string)<br/>    labels                        = optional(map(string), {})<br/>    purpose                       = optional(string, "ENCRYPT_DECRYPT")<br/>    rotation_period               = optional(string, "7776000s") # 90 days in seconds<br/>    skip_initial_version_creation = optional(bool, false)<br/><br/>    version_template = optional(object({<br/>      algorithm        = string<br/>      protection_level = string<br/>    }))<br/><br/>    iam = optional(map(set(string)), {})<br/>    iam_bindings = optional(map(object({<br/>      members = set(string)<br/>      role    = string<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        title       = string<br/>      }))<br/>    })), {})<br/>    iam_members = optional(map(object({<br/>      member = string<br/>      role   = string<br/>      condition = optional(object({<br/>        description = optional(string)<br/>        expression  = string<br/>        title       = string<br/>      }))<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix prepended to `key_ring_name`. Cannot be an empty string — use null to omit. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If not provided, the provider project is used. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_key_ids"></a> [key\_ids](#output\_key\_ids) | Map of crypto key IDs keyed by the name supplied in `var.keys`. Each value is the fully qualified resource ID in the format `projects/PROJECT/locations/LOCATION/keyRings/RING/cryptoKeys/NAME`. Use these when granting Cloud KMS encrypter/decrypter roles to GCP service agents, e.g. for CMEK on Cloud SQL, GCS, or Compute. |
| <a name="output_key_ring_id"></a> [key\_ring\_id](#output\_key\_ring\_id) | The fully qualified resource ID of the KMS key ring in the format `projects/PROJECT/locations/LOCATION/keyRings/NAME`. Use this when granting IAM roles on the key ring or referencing the key ring from other resources. |
| <a name="output_key_ring_name"></a> [key\_ring\_name](#output\_key\_ring\_name) | The short name of the KMS key ring. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
