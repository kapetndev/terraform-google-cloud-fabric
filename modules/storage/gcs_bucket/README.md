# Google Cloud Storage Bucket

Terraform module to create and manage GCS buckets with the following
capabilities:

- Configurable storage classes and location types
- Object versioning and autoclass for automatic storage tier transitions
- Lifecycle rules for age-based or condition-based object management
- Retention policies with minimum retention periods and optional bucket locking
- Object holds (event-based and retention) to prevent premature deletion for
  compliance requirements
- Hierarchical namespace for directory-like organisation
- CORS configuration for cross-origin requests
- Static website hosting
- Public access prevention and uniform bucket-level access for security controls
- Access logging to track bucket usage
- IAM bindings for bucket and object permissions with conditional access
  policies

## Usage

```hcl
module "my_bucket" {
  source   = "github.com/kapetndev/terraform-google-cloud-fabric//modules/storage/gcs_bucket?ref=v0.1.0
  name     = "my-bucket"
  location = "europe-west2"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.9.0 |

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.bucket](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_binding.bindings](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_member.non_authoritative](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Compute zone or region the bucket will sit in. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the bucket. | `string` | n/a | yes |
| <a name="input_autoclass"></a> [autoclass](#input\_autoclass) | Enable autoclass for the bucket. | <pre>object({<br/>    enabled                = bool<br/>    terminal_storage_class = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | CORS configuration for the bucket. | <pre>object({<br/>    max_age_seconds         = optional(number, 3600)<br/>    methods                 = list(string)<br/>    origins                 = list(string)<br/>    response_headers_values = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_default_event_based_hold"></a> [default\_event\_based\_hold](#input\_default\_event\_based\_hold) | Enable default event-based hold for the bucket. | `bool` | `false` | no |
| <a name="input_enable_object_retention"></a> [enable\_object\_retention](#input\_enable\_object\_retention) | Enable object retention for the bucket. | `bool` | `false` | no |
| <a name="input_encryption_key_name"></a> [encryption\_key\_name](#input\_encryption\_key\_name) | The full path to the encryption key used for to encrypt objects inserted into the bucket. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | If true, allows the bucket to be destroyed even if it contains objects. This is a dangerous operation and should be used with caution. | `bool` | `false` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_hierarchical_namespace"></a> [hierarchical\_namespace](#input\_hierarchical\_namespace) | Enable hierarchical namespace for the bucket. Also enables uniform bucket-level access. | `bool` | `false` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings in `{KEY => {members = [MEMBERS], role = ROLE, condition = {}}}` format. Role/member pairs cannot appear in both this variable and `iam`. Keys are arbitrary. | <pre>map(object({<br/>    members = set(string)<br/>    role    = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of user defined key/value label pairs to assign to the bucket. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle rules for the bucket. | <pre>set(object({<br/>    action_type = string<br/>    action = object({<br/>      storage_class = string<br/>    })<br/>    condition = object({<br/>      age                                     = optional(number)<br/>      created_before                          = optional(string)<br/>      custom_time_before                      = optional(string)<br/>      days_since_custom_time                  = optional(number)<br/>      days_since_noncurrent_time              = optional(number)<br/>      matches_prefix                          = optional(list(string))<br/>      matches_storage_class                   = optional(list(string))<br/>      matches_suffix                          = optional(list(string))<br/>      noncurrent_time_before                  = optional(string)<br/>      num_newer_versions                      = optional(number)<br/>      send_age_if_zero                        = optional(bool)<br/>      send_days_since_custom_time_if_zero     = optional(bool)<br/>      send_days_since_noncurrent_time_if_zero = optional(bool)<br/>      send_num_newer_versions_if_zero         = optional(bool)<br/>      with_state                              = optional(string)<br/>    })<br/>  }))</pre> | `[]` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Logging configuration for the bucket. | <pre>object({<br/>    log_bucket        = string<br/>    log_object_prefix = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix applied to the bucket name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention) | Public access prevention for the bucket. | `string` | `"inherited"` | no |
| <a name="input_requester_pays"></a> [requester\_pays](#input\_requester\_pays) | Enable requester pays for the bucket. | `bool` | `false` | no |
| <a name="input_retention_policy"></a> [retention\_policy](#input\_retention\_policy) | Retention policy for the bucket. | <pre>object({<br/>    retention_period = number<br/>    is_locked        = optional(bool)<br/>  })</pre> | `null` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Storage class for the bucket. | `string` | `"STANDARD"` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Enable uniform bucket-level access for the bucket. | `bool` | `false` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Enable versioning for the bucket. | `bool` | `false` | no |
| <a name="input_website"></a> [website](#input\_website) | Static website configuration for the bucket. | <pre>object({<br/>    main_page_suffix = optional(string)<br/>    not_found_page   = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the bucket. |
| <a name="output_url"></a> [url](#output\_url) | Bucket URL. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
