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

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

<!-- pyml disable-num-lines 4 md013 -->
| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.71.0 |
| [random](https://registry.terraform.io/providers/hashicorp/random/latest) | >= 3.5.1 |

## Resources

<!-- pyml disable-num-lines 8 md013 -->
| Name | Type |
|------|------|
| [`random_id.project_id`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [`google_project.project`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project) | resource |
| [`google_project_service.services[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_service) | resource |
| [`google_project_iam_binding.authoritative[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam) | resource |
| [`google_project_iam_member.non_authoritative[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam) | resource |
| [`google_tags_tag_binding.binding[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/tags_tag_binding) | resource |

## Inputs

<!-- pyml disable-num-lines 16 md013 -->
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | The project name. An ID suffix will be added to the name to ensure uniqueness | `string` | | yes |
| `parent` | The parent folder or organization in 'folders/folder\_id' or 'organizations/org\_id' format | `string` | `null` | yes |
| `auto_create_network` | Whether to create the default network for the project | `bool` | `false` | no |
| `billing_account` | The alphanumeric billing account ID | `string` | `null` | no |
| `descriptive_name` | The authoritative name of the project. Used instead of `name` variable | `string` | `null` | no |
| `disable_dependent_services` | Whether to disable dependent services when disabling a service | `bool` | `false` | no |
| `disable_on_destroy` | Whether to disable the service when the resource is destroyed | `bool` | `true` | no |
| `group_iam` | Authoritative IAM binding for organization groups, in `{GROUP_EMAIL => [ROLES]}` format. Group emails must be static. Can be used in combination with the `iam` variable | `map(set(string))` | `{}` | no |
| `iam` | Authoritative IAM bindings in `{ROLE => [MEMBERS]}` format | `map(set(string))` | `{}` | no |
| `iam_member` | Non-authoritative IAM bindings in `{ROLE = [MEMBERS]}` format. Can be used in combination with the `iam` variable. Typically this will be used for default service accounts or other Google managed resources | `map(set(string))` | `{}` | no |
| `prefix` | An optional prefix used to generate the project id | `string` | `null` | no |
| `project_id` | The ID of the project. If it is not provided the name of the project is used followed by a random suffix | `string` | null | no |
| `services` | A list of services to enable in the project | `set(string)` | `[]` | no |
| `tag_bindings` | Tag bindings for this project, in `{key => tag}` value id format | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `project_id` | The project ID |
| `project_number` | The numeric identifier of the project |
