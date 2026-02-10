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
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |

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
| <a name="input_location"></a> [location](#input\_location) | The GCS location for the bucket. Can be a region (e.g. `europe-west2`), a dual-region (e.g. `EUR4`), or a multi-region (e.g. `EU`). See https://cloud.google.com/storage/docs/locations. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the bucket. Must be globally unique across all of GCS. | `string` | n/a | yes |
| <a name="input_autoclass"></a> [autoclass](#input\_autoclass) | Autoclass configuration for the bucket. When set, GCS automatically transitions<br/>objects to colder storage classes based on access patterns. Mutually exclusive<br/>with a fixed `storage_class` of NEARLINE, COLDLINE, or ARCHIVE.<br/><br/>(Optional) terminal\_storage\_class - The storage class that objects transition to if they are not read for a long period. Must be one of `NEARLINE` or `ARCHIVE`. Defaults to `NEARLINE`. | <pre>object({<br/>    terminal_storage_class = optional(string, "NEARLINE")<br/>  })</pre> | `null` | no |
| <a name="input_cors"></a> [cors](#input\_cors) | CORS configuration for the bucket. Required when the bucket serves assets<br/>accessed from a different origin (e.g. a frontend application).<br/><br/>(Required) methods - HTTP methods to allow, e.g. ["GET", "HEAD"].<br/>(Required) origins - Origins to allow, e.g. ["https://example.com"].<br/>(Required) response\_header\_values - HTTP headers the browser can expose to the requesting origin.<br/>(Optional) max\_age\_seconds - How long the browser can cache a preflight response, in seconds. Defaults to 3600. | <pre>object({<br/>    max_age_seconds        = optional(number, 3600)<br/>    methods                = list(string)<br/>    origins                = list(string)<br/>    response_header_values = list(string)<br/>  })</pre> | `null` | no |
| <a name="input_default_event_based_hold"></a> [default\_event\_based\_hold](#input\_default\_event\_based\_hold) | Enable default event-based hold for new objects in the bucket. When enabled, objects cannot be deleted or replaced until the hold is explicitly released. Cannot be used with `hierarchical_namespace`. | `bool` | `false` | no |
| <a name="input_enable_object_retention"></a> [enable\_object\_retention](#input\_enable\_object\_retention) | Enable object retention for the bucket. When enabled, individual objects can be assigned a retention period during which they cannot be deleted or overwritten. Requires uniform bucket-level access. | `bool` | `false` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | If true, allows the bucket to be destroyed even if it contains objects. This is a dangerous operation and should be used with caution. Defaults to false. | `bool` | `false` | no |
| <a name="input_group_iam"></a> [group\_iam](#input\_group\_iam) | Authoritative IAM binding for organisation groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable. | `map(set(string))` | `{}` | no |
| <a name="input_hierarchical_namespace"></a> [hierarchical\_namespace](#input\_hierarchical\_namespace) | Enable hierarchical namespace for the bucket, which organises objects into a directory structure. Automatically enables uniform bucket-level access. Cannot be used with `default_event_based_hold`. | `bool` | `false` | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format. | `map(set(string))` | `{}` | no |
| <a name="input_iam_bindings"></a> [iam\_bindings](#input\_iam\_bindings) | Authoritative IAM bindings with conditions in `{ROLE => {members = [MEMBERS], condition = {}}}` format. Roles cannot appear in both this variable and `iam`. Keys are the IAM role. | <pre>map(object({<br/>    members = set(string)<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_members"></a> [iam\_members](#input\_iam\_members) | Non-authoritative IAM bindings in `{KEY => {member = MEMBER, role = ROLE, condition = {}}}` format. Can be used in combination with the `iam` and `iam_bindings` variables. Keys are arbitrary. | <pre>map(object({<br/>    member = string<br/>    role   = string<br/>    condition = optional(object({<br/>      description = optional(string)<br/>      expression  = string<br/>      title       = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of user defined key/value label pairs to assign to the bucket. | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | Lifecycle rules for the bucket. Each rule defines an action to take when an<br/>object matches the given condition.<br/><br/>(Required) action\_type - The action to take. Must be one of `Delete`, `SetStorageClass`, or `AbortIncompleteMultipartUpload`.<br/><br/>(Optional) action - The action to take when the condition is met.<br/>(Required) action.storage\_class - The target storage class for `SetStorageClass` actions.<br/><br/>(Optional) condition - The condition under which the action will be taken. If not specified, the action will be taken on all objects in the bucket.<br/>(Optional) condition.age - Age of the object in days.<br/>(Optional) condition.created\_before - Objects created before this date (YYYY-MM-DD).<br/>(Optional) condition.custom\_time\_before - Objects whose custom time is before this date (YYYY-MM-DD).<br/>(Optional) condition.days\_since\_custom\_time - Days since the object's custom time.<br/>(Optional) condition.days\_since\_noncurrent\_time - Days since the object became noncurrent.<br/>(Optional) condition.matches\_prefix - List of object name prefixes to match.<br/>(Optional) condition.matches\_storage\_class - List of storage classes to match.<br/>(Optional) condition.matches\_suffix - List of object name suffixes to match.<br/>(Optional) condition.noncurrent\_time\_before - Noncurrent objects before this date (YYYY-MM-DD).<br/>(Optional) condition.num\_newer\_versions - Number of newer versions required before this version matches.<br/>(Optional) condition.with\_state - Match objects by their live state. One of `LIVE`, `ARCHIVED`, or `ANY`. | <pre>set(object({<br/>    action_type = string<br/>    action = optional(object({<br/>      storage_class = string<br/>    }))<br/>    condition = optional(object({<br/>      age                                     = optional(number)<br/>      created_before                          = optional(string)<br/>      custom_time_before                      = optional(string)<br/>      days_since_custom_time                  = optional(number)<br/>      days_since_noncurrent_time              = optional(number)<br/>      matches_prefix                          = optional(list(string))<br/>      matches_storage_class                   = optional(list(string))<br/>      matches_suffix                          = optional(list(string))<br/>      noncurrent_time_before                  = optional(string)<br/>      num_newer_versions                      = optional(number)<br/>      send_age_if_zero                        = optional(bool)<br/>      send_days_since_custom_time_if_zero     = optional(bool)<br/>      send_days_since_noncurrent_time_if_zero = optional(bool)<br/>      send_num_newer_versions_if_zero         = optional(bool)<br/>      with_state                              = optional(string)<br/>    }))<br/>  }))</pre> | `[]` | no |
| <a name="input_logging_config"></a> [logging\_config](#input\_logging\_config) | Access log delivery configuration. Logs are written as objects to the specified<br/>bucket.<br/><br/>(Required) log\_bucket - The name of the bucket to which access logs are delivered.<br/>(Optional) log\_object\_prefix - Prefix for log object names. Defaults to the bucket name. | <pre>object({<br/>    log_bucket        = string<br/>    log_object_prefix = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix prepended to `name` to form the full bucket name. Cannot be an empty string — use null to omit. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention) | Public access prevention policy for the bucket. `enforced` blocks all public access regardless of IAM policies. `inherited` defers to the organisation policy. Defaults to `inherited`. | `string` | `"inherited"` | no |
| <a name="input_requester_pays"></a> [requester\_pays](#input\_requester\_pays) | When enabled, the requester of each operation is billed for network and operation costs rather than the bucket owner. Defaults to false. | `bool` | `false` | no |
| <a name="input_retention_policy"></a> [retention\_policy](#input\_retention\_policy) | Bucket-level retention policy. Objects cannot be deleted or overwritten until<br/>their retention period has elapsed.<br/><br/>(Required) retention\_period - Retention period in seconds.<br/>(Optional) is\_locked - If true, the retention policy cannot be reduced or removed. Defaults to false. Warning: locking a retention policy is irreversible. | <pre>object({<br/>    retention_period = number<br/>    is_locked        = optional(bool, false)<br/>  })</pre> | `null` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Default storage class for objects in the bucket. Applies to new objects unless overridden by a lifecycle rule or autoclass. Must be one of `STANDARD`, `MULTI_REGIONAL`, `REGIONAL`, `NEARLINE`, `COLDLINE`, or `ARCHIVE`. Defaults to `STANDARD`. | `string` | `"STANDARD"` | no |
| <a name="input_uniform_bucket_level_access"></a> [uniform\_bucket\_level\_access](#input\_uniform\_bucket\_level\_access) | Enables uniform bucket-level access, which disables object-level ACLs and enforces IAM-only access control. Defaults to true. Automatically enabled when `hierarchical_namespace` is true. | `bool` | `true` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Enable object versioning for the bucket. When enabled, overwriting or deleting an object creates a new version rather than permanently removing data. Defaults to true. | `bool` | `true` | no |
| <a name="input_website"></a> [website](#input\_website) | Static website configuration. When set, the bucket serves its contents as a website.<br/><br/>(Optional) main\_page\_suffix - The object to serve when a directory is requested, e.g. `index.html`.<br/>(Optional) not\_found\_page - The object to serve for 404 responses, e.g. `404.html`. | <pre>object({<br/>    main_page_suffix = optional(string)<br/>    not_found_page   = optional(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | ID of the bucket. |
| <a name="output_url"></a> [url](#output\_url) | Bucket URL. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
