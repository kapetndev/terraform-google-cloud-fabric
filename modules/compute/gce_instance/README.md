# Google Compute Engine Instance

Terraform module to create and manage GCE virtual machine instances with
configurable machine types, boot disks, and attached persistent disks. It
manages network interfaces, supporting both optional external IP addresses and
custom internal addressing.

## Usage

```hcl
module "vpc" {
  source = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/vpc_network?ref=v0.1.0"
  name   = "my-vpc"

  subnets = [
    {
      name          = "my-vpc"
      region        = "europe-west2"
      ip_cidr_range = "10.0.0.0/24"
    },
  ]
}

module "instance" {
  source          = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/gce_instance?ref=v0.1.0"
  hostname        = "app.c.my-project.internal"
  name            = "my-instance"
  service_account = "my-instance-sa@my-project.iam.gserviceaccount.com"
  zone            = "europe-west2-a"

  network_interfaces = [
    { subnetwork = module.vpc.subnets["europe-west2/my-vpc"].self_link },
  ]
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
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_disk.persistent_disks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_disk) | resource |
| [google_compute_instance.instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [random_id.instance_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The email of the GCP service account to assign to the instance.<br/><br/>A dedicated, minimal service account should always be created and provided<br/>here. Do not use the Compute Engine default service account<br/>(PROJECT\_NUMBER-compute@developer.gserviceaccount.com) — it has project-wide<br/>editor permissions and represents a significant privilege escalation risk if an<br/>instance is compromised. | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The zone in which to create the instance. If not provided, the provider zone is used. | `string` | n/a | yes |
| <a name="input_attached_disks"></a> [attached\_disks](#input\_attached\_disks) | Existing persistent disks to attach to the instance. These disks are managed<br/>outside this module — only the attachment is controlled here. The disk resource<br/>itself is not created, modified, or destroyed by this module.<br/><br/>(Required) source - Name or `self_link` of the existing disk to attach.<br/><br/>(Optional) device\_name - Name under which the disk is exposed inside the instance at `/dev/disk/by-id/google-DEVICE_NAME`. Defaults to the value of `source`.<br/>(Optional) mode - Attachment mode. `READ_WRITE` (default) or `READ_ONLY`. | <pre>list(object({<br/>    device_name = optional(string)<br/>    mode        = optional(string, "READ_WRITE")<br/>    source      = string<br/>  }))</pre> | `[]` | no |
| <a name="input_boot_disk"></a> [boot\_disk](#input\_boot\_disk) | Boot disk configuration. Exactly one of initialization\_params or source must be<br/>set.<br/><br/>(Optional) auto\_delete - Whether to delete the boot disk when the instance is deleted. Defaults to true.<br/>(Optional) source - The name or `self_link` of an existing disk to attach as the boot disk. Mutually exclusive with `initialization_params`.<br/><br/>(Optional) initialization\_params - Parameters for a new disk created with the instance. Mutually exclusive with `source`.<br/>(Optional) initialization\_params.image - The image from which to initialise the disk. Accepts `self_link`, `projects/PROJECT/global/images/IMAGE`, `family/FAMILY`, or short forms. Defaults to the latest Debian 12 (Bookworm) image.<br/>(Optional) initialization\_params.size - Disk size in GB. Defaults to 20.<br/>(Optional) initialization\_params.type - Disk type. One of pd-standard, pd-ssd, pd-balanced, or pd-extreme. Defaults to pd-ssd. | <pre>object({<br/>    auto_delete = optional(bool, true)<br/>    source      = optional(string)<br/>    initialization_params = optional(object({<br/>      image = optional(string, "projects/debian-cloud/global/images/family/debian-12")<br/>      size  = optional(number, 20)<br/>      type  = optional(string, "pd-ssd")<br/>    }))<br/>  })</pre> | <pre>{<br/>  "initialization_params": {}<br/>}</pre> | no |
| <a name="input_description"></a> [description](#input\_description) | A human-readable description of the instance resource. | `string` | `null` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | Fully qualified, authoritative name of the instance. When set, `name` is ignored and this value is used directly as the instance name with no suffix appended. | `string` | `null` | no |
| <a name="input_hostname"></a> [hostname](#input\_hostname) | A custom hostname for the instance. Must be a fully qualified DNS name and RFC-1035-valid — a series of labels 1-63 characters long matching `[a-z]([-a-z0-9]*[a-z0-9])`, joined with periods, not exceeding 253 characters in total. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | User defined resource labels to assign to the instance. | `map(string)` | `{}` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | The Compute Engine machine type for the instance, e.g. `e2-medium`, `n2-standard-2`. | `string` | `"e2-medium"` | no |
| <a name="input_managed_disks"></a> [managed\_disks](#input\_managed\_disks) | Persistent disks to create and attach to the instance. This module owns the<br/>lifecycle of these disks — they are created as `google_compute_disk` resources<br/>with `prevent_destroy = true` to guard against accidental data loss.<br/><br/>To destroy a managed disk, first remove it from this variable and apply, then<br/>run destroy, or manage the disk outside this module.<br/><br/>(Required) name - Unique name for the disk resource, required by GCE.<br/>(Required) size - Disk size in GB.<br/><br/>(Optional) description - Human-readable description of the disk.<br/>(Optional) device\_name - Name under which the disk is exposed inside the instance at `/dev/disk/by-id/google-DEVICE_NAME`. Defaults to the disk name.<br/>(Optional) source - Name or `self_link` of the image or snapshot to initialise the disk from. Required when `source_type` is `image` or `snapshot`. Omit to create a blank disk.<br/><br/>(Optional) source\_type - How to initialise the disk. Defaults to `blank`. One of:<br/>  `blank`    - Create an empty disk. `source` must not be set.<br/>  `image`    - Initialise the disk from the image named in `source`.<br/>  `snapshot` - Restore the disk from the snapshot named in `source`.<br/><br/>(Optional) options - Disk options.<br/>(Optional) options.mode - Attachment mode. `READ_WRITE` (default) or `READ_ONLY`.<br/>(Optional) options.type - Disk type. One of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`. Defaults to `pd-ssd`. | <pre>list(object({<br/>    description = optional(string)<br/>    device_name = optional(string)<br/>    name        = string<br/>    size        = number<br/>    source      = optional(string)<br/>    source_type = optional(string, "blank")<br/>    options = optional(<br/>      object({<br/>        mode = optional(string, "READ_WRITE")<br/>        type = optional(string, "pd-ssd")<br/>      }),<br/>      {<br/>        mode = "READ_WRITE"<br/>        type = "pd-ssd"<br/>      }<br/>    )<br/>  }))</pre> | `[]` | no |
| <a name="input_metadata"></a> [metadata](#input\_metadata) | User-defined key/value metadata pairs to make available from within the instance. Merged with the module's required security metadata — caller-supplied values take precedence for non-reserved keys. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the instance. Used as a prefix for the generated instance name unless `descriptive_name` is set. | `string` | `null` | no |
| <a name="input_network_interfaces"></a> [network\_interfaces](#input\_network\_interfaces) | Network interfaces to attach to the instance. At least one interface must be<br/>provided. For each interface, at least one of network or subnetwork must be set.<br/><br/>(Optional) external\_access - Whether to assign a public IP (NAT) to this interface. Defaults to false. Avoid enabling this on instances in private clusters or subnets without a Cloud NAT gateway.<br/>(Optional) internal\_address - Static private IP address. If not set, GCP assigns one automatically.<br/>(Optional) nat\_address - Static external IP to use when `external_access` is true. If not set, an ephemeral IP is assigned automatically.<br/>(Optional) network - Name or `self_link` of the VPC network. If not provided, inferred from subnetwork.<br/>(Optional) subnetwork - Name or `self_link` of the subnetwork. If not provided, inferred from network. | <pre>list(object({<br/>    external_access  = optional(bool, false)<br/>    internal_address = optional(string)<br/>    nat_address      = optional(string)<br/>    network          = optional(string)<br/>    subnetwork       = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_oauth_scopes"></a> [oauth\_scopes](#input\_oauth\_scopes) | Additional GCP API OAuth scopes granted to the instance service account, merged with the module's required baseline scopes. Additional scopes are typically only needed when workloads use Application Default Credentials rather than Workload Identity, which is discouraged. | `set(string)` | `[]` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix prepended to `name` when generating the instance name. Has no effect when `descriptive_name` is set. Cannot be an empty string — use null to omit. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project in which to create the instance. Defaults to the provider project if not set. | `string` | `null` | no |
| <a name="input_running"></a> [running](#input\_running) | Whether the instance should be running. When false, the instance is kept in a `TERMINATED` state. Useful for cost management in non-production environments. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Network tags to attach to the instance. Used to identify the instance for applicable firewall rules and network routes. | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_external_ip"></a> [external\_ip](#output\_external\_ip) | The external IP address of the first network interface, if one is assigned. Null when external\_access is false on the first interface. |
| <a name="output_id"></a> [id](#output\_id) | The server-assigned unique identifier of the instance. |
| <a name="output_internal_ip"></a> [internal\_ip](#output\_internal\_ip) | The internal IP address of the first network interface. Use this for service configurations, DNS records, or firewall rules that reference the instance directly. |
| <a name="output_name"></a> [name](#output\_name) | The name of the instance as known to the GCP API. Use this when referencing the instance from other resources. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | The URI of the instance. Use this to reference the instance in other GCP resources such as instance groups, load balancer backends, and IAM bindings. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
