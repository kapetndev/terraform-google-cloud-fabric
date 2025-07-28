# gce\_instance

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
  source   = "git::https://github.com/kapetndev/terraform-google-compute.git//modules/gce_instance?ref=v0.1.0"
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

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.67.0 |

## Resources

| Name | Type |
|------|------|
| [`google_compute_disk.persistent_disks[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [`google_compute_instance.instance`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | A unique name for the resource, required by GCE. Changing this forces a new resource to be created | `string` | | yes |
| `zone` | The zone that the machine should be created in. If it is not provided, the provider zone is used | `string` | | yes |
| `attached_disks` | A list of additional disks to attach to the instance | `list(object{...})` | `[]` | no |
| `attached_disks[*].name` | A unique name for the resource, required by GCE | `string` | | yes |
| `attached_disks[*].size` | The size of the image in gigabytes | `number` | | yes |
| `attached_disks[*].description` | A brief description of the resource | `string` | `null` | no |
| `attached_disks[*].device_name` | The name with which attached disk will be accessible. On the instance, this device will be `/dev/disk/by-id/google-{{device_name}}` | `string` | `null` | no |
| `attached_disks[*].source` | The name or self_link of an existing disk (such as those managed by `google_compute_disk`), disk image, or snapshot | `string` | `null` | no |
| `attached_disks[*].source_type` | The type of the disk source, either `attach`, `image`, or `snapshot`. Leaving this empty is the same as `attach` but the `source` is ignored | `string` | `null` | no |
| `attached_disks[*].options` | The options to use for this disk | `object{...}` | `{}` | no |
| `attached_disks[*].options.mode` | The mode in which to attach this disk, either `READ_WRITE` or `READ_ONLY`. If not specified, the default is to attach the disk in `READ_WRITE` mode | `string` | `READ_WRITE`| no |
| `attached_disks[*].options.type` | The type of the disk. Possible values are `pd-standard` and `pd-ssd` | `string` | `pd-ssd` | no |
| `boot_disk` | The boot disk for the instance | `object{...}` | `{}` | no |
| `boot_disk.auto_delete` | Whether the disk will be auto-deleted when the instance is deleted | `bool` | `true` | no |
| `boot_disk.initialization_params` | The parameters for a new disk that will be created alongside the new instance. Either `initialization_params` or `source` must be set | `object` | `{}` | no |
| `boot_disk.initialization_params.image` | The image from which to initialize this disk. This can be one of: the image's `self_link`, `projects/{project}/global/images/{image}`, `projects/{project}/global/images/family/{family}`, `global/images/{image}`, `global/images/family/{family}`, `family/{family}`, `{project}/{family}`, `{project}/{image}`, `{family}`, or `{image}`. If referred by family, the images names must include the family name. If they don't, use the `google_compute_image` resource instead | `string` | `projects/debian-cloud/global/images/family/debian-11` | no |
| `boot_disk.initialization_params.size` | The size of the image in gigabytes. If not specified, it will inherit the size of its base image | `number` | `20` | no |
| `boot_disk.initialization_params.type` | The GCE disk type. Can be either `pd-standard` or `pd-ssd` | `string` | `pd-standard` | no |
| `boot_disk.source` | The name or `self_link` of an existing disk (such as those managed by `google_compute_disk`), or disk image | `string` | `null` | no |
| `description` | A brief description of this resource | `string` | `null` | no |
| `hostname` | A custom hostname for the instance. Must be a fully qualified DNS name and RFC-1035-valid. Valid format is a series of labels 1-63 characters long matching the regular expression [a-z]([-a-z0-9]*[a-z0-9]), concatenated with periods. The entire hostname must not exceed 253 characters. Changing this forces a new resource to be created | `string` | `null` | no |
| `labels` | A map of user defined key/value label pairs to assign to the instance | `map(string)` | `{}` | no |
| `machine_type` | The machine type to create | `string` | `n1-standard-1` | no |
| `metadata` | A map of user defined key/value metadata pairs to make available from within the instance | `map(string)` | `{}` | no |
| `network_interfaces` | A list of network interfaces to attach to the instance | `list(object{...})` | `[]` | no |
| `network_interfaces[*].external_access` | Whether to assign a public IP address to this interface | `bool` | `false` | no |
| `network_interfaces[*].internal_address` | The private IP address to assign to the instance. If not given, the address will be automatically assigned | `string` | `null` | no |
| `network_interfaces[*].nat_address` | The IP address that will be 1:1 mapped to this interface. If not given, and external access is enabled, the address will be automatically assigned | `string` | `null` | no |
| `network_interfaces[*].network` | The name or `self_link` of the network to attach this interface to. At least one of `network` or `subnetwork` must be provided. If `network` isn't provided it will be inferred from `subnetwork` | `string` | `null` | no |
| `network_interfaces[*].subnetwork` | The name or `self_link` of the subnetwork to attach this interface to. At least one of `network` or `subnetwork` must be provided | `string` | `null` |  no |
| `oauth_scopes` | A list of service scopes. Both OAuth2 URLs and gcloud short names are supported. To allow full access to all Cloud APIs, use the `cloud-platform` scope. *Note*: `allow_stopping_for_update` must be set to `true` or the instance must have a `desired_status` of `TERMINATED` in order to update this field | `set(string)` | `[]` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
| `running` | Whether the instance is running | `bool` | `true` | no |
| `service_account_email` | The email address of the service account to attach to the instance. If not provided, the default Compute Engine service account will be used | `string` | `null` | no |
| `tags` | A list of network tags to attach to the instance | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| `instance_id` | The server-assigned unique identifier of the instance |
