# Google Compute Engine Instance

Terraform module to create and manage Google Compute Engine virtual machines.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
data "google_compute_image" "instance_image" {
  name = "ubuntu-1804-bionic-v20200414"
}

data "google_compute_subnetwork" "europe_west2" {
  name   = "default"
  region = "europe-west2"
}

module "instance" {
  source   = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/gce_instance?ref=v0.1.0"
  hostname = "app.c.my-project.internal"
  name     = "my-instance"
  zone     = "europe-west2-a"

  boot_disk = {
    initialize_params = {
      image = data.google_compute_image.instance_image.self_link
    }
  }

  network_interfaces = [
    { subnetwork = data.google_compute_subnetwork.europe_west2.self_link },
  ]

  tags = [
    "https-server",
    "ssh-server",
  ]
}
```

## Examples

- [virtual-machine](../../examples/virtual-machine) - Create a virtual machine.

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.11.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.11.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_disk.persistent_disks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | A unique name for the resource, required by GCE. Changing this forces a new resource to be created. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone that the machine should be created in. If it is not provided, the provider zone is used. | `string` | n/a | yes |
| <a name="input_attached_disks"></a> [attached\_disks](#input\_attached\_disks) | A list of additional disks to attach to the instance.<br/><br/>(Required) name - A unique name for the resource, required by GCE.<br/>(Required) size - The size of the disk attached to the instance, specified in GB.<br/><br/>(Optional) description - A brief description of the resource.<br/>(Optional) device\_name - The name with which attached disk will be accessible. On the instance, this device will be `/dev/disk/by-id/google-{{device_name}}`.<br/>(Optional) source - The name or self\_link of an existing disk (such as those managed by `google_compute_disk`), disk image, or snapshot.<br/>(Optional) source\_type - The type of the disk source, either `attach`, `image`, or `snapshot`. Leaving this empty is the same as `attach` but the `source` is ignored.<br/>(Optional) options - The options to use for this disk.<br/>(Optional) options.mode - The mode in which to attach this disk, either `READ_WRITE` or `READ_ONLY`. If not specified, the default is to attach the disk in `READ_WRITE` mode.<br/>(Optional) options.type - The type of disk to use, either `pd-standard` or `pd-ssd`. | <pre>list(object({<br/>    description = optional(string)<br/>    device_name = optional(string)<br/>    name        = string<br/>    size        = string<br/>    source      = optional(string)<br/>    source_type = optional(string)<br/>    options = optional(<br/>      object({<br/>        mode = optional(string, "READ_WRITE")<br/>        type = optional(string, "pd-ssd")<br/>      }),<br/>      {<br/>        mode = "READ_WRITE"<br/>        type = "pd-ssd"<br/>      }<br/>    )<br/>  }))</pre> | `[]` | no |
| <a name="input_boot_disk"></a> [boot\_disk](#input\_boot\_disk) | The boot disk for the instance.<br/><br/>(Optional) auto\_delete - Whether the disk will be auto-deleted when the instance is deleted. Default value is true.<br/>(Optional) initialization\_params - The parameters for a new disk that will be created alongside the new instance. Either `initialization_params` or `source` must be set.<br/>(Optional) initialization\_params.image - The image from which to initialize this disk. This can be one of: the image's `self_link`, `projects/{project}/global/images/{image}`, `projects/{project}/global/images/family/{family}`, `global/images/{image}`, `global/images/family/{family}`, `family/{family}`, `{project}/{family}`, `{project}/{image}`, `{family}`, or `{image}`. If referred by family, the images names must include the family name. If they don't, use the `google_compute_image` resource instead.<br/>(Optional) initialization\_params.size - The size of the image, specified in GB. If not specified, it will inherit the size of its base image.<br/>(Optional) initialization\_params.type - The type of the disk. Default value is `pd-ssd`. Possible values are `pd-standard` and `pd-ssd`.<br/>(Optional) source - The name or `self_link` of an existing disk (such as those managed by `google_compute_disk`), or disk image. | <pre>object({<br/>    auto_delete = optional(bool, true)<br/>    source      = optional(string)<br/>    initialization_params = optional(object({<br/>      image = optional(string, "projects/debian-cloud/global/images/family/debian-11")<br/>      size  = optional(number, 20)<br/>      type  = optional(string, "pd-ssd")<br/>    }))<br/>  })</pre> | <pre>{<br/>  "initialization_params": {}<br/>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | A brief description of this resource. | `string` | `null` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | A custom hostname for the instance. Must be a fully qualified DNS name and RFC-1035-valid. Valid format is a series of labels 1-63 characters long matching the regular expression [a-z]([-a-z0-9]*[a-z0-9]), concatenated with periods. The entire hostname must not exceed 253 characters. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | A map of user defined key/value label pairs to assign to the instance. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The machine type to create. | `string` | `"n1-standard-1"` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | A map of user defined key/value metadata pairs to make available from within the instance. | `map(string)` | `{}` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | A list of network interfaces to attach to the instance.<br/><br/>(Optional) external\_access - Whether to assign a public IP address to this interface. Default value is `false`.<br/>(Optional) internal\_address - The private IP address to assign to the instance. If not given, the address will be automatically assigned.<br/>(Optional) nat\_address - The IP address that will be 1:1 mapped to this interface. If not given, and external access is enabled, the address will be automatically assigned.<br/>(Optional) network - The name or `self_link` of the network to attach this interface to. At least one of `network` or `subnetwork` must be provided. If `network` isn't provided it will be inferred from `subnetwork`.<br/>(Optional) subnetwork - The name or `self_link` of the subnetwork to attach this interface to. At least one of `network` or `subnetwork` must be provided. | <pre>list(object({<br/>    external_access  = optional(bool, false)<br/>    internal_address = optional(string)<br/>    nat_address      = optional(string)<br/>    network          = optional(string)<br/>    subnetwork       = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | A list of service scopes. Both OAuth2 URLs and gcloud short names are supported. To allow full access to all Cloud APIs, use the `cloud-platform` scope. *Note*: `allow_stopping_for_update` must be set to `true` or the instance must have a `desired_status` of `TERMINATED` in order to update this field. | `set(string)` | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_running"></a> [running](#input\_running) | Whether the instance is running. | `bool` | `true` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | The email address of the service account to attach to the instance. If not provided, the default Compute Engine service account will be used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A list of network tags to attach to the instance. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | The server-assigned unique identifier of the instance. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
