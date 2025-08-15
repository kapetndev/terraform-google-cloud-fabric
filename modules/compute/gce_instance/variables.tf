variable "attached_disks" {
  description = <<EOF
A list of additional disks to attach to the instance.

(Required) name - A unique name for the resource, required by GCE.
(Required) size - The size of the disk attached to the instance, specified in GB.

(Optional) description - A brief description of the resource.
(Optional) device_name - The name with which attached disk will be accessible. On the instance, this device will be `/dev/disk/by-id/google-{{device_name}}`.
(Optional) source - The name or self_link of an existing disk (such as those managed by `google_compute_disk`), disk image, or snapshot.
(Optional) source_type - The type of the disk source, either `attach`, `image`, or `snapshot`. Leaving this empty is the same as `attach` but the `source` is ignored.
(Optional) options - The options to use for this disk.
(Optional) options.mode - The mode in which to attach this disk, either `READ_WRITE` or `READ_ONLY`. If not specified, the default is to attach the disk in `READ_WRITE` mode.
(Optional) options.type - The type of disk to use, either `pd-standard` or `pd-ssd`.
EOF
  type = list(object({
    description = optional(string)
    device_name = optional(string)
    name        = string
    size        = string
    source      = optional(string)
    source_type = optional(string)
    options = optional(
      object({
        mode = optional(string, "READ_WRITE")
        type = optional(string, "pd-ssd")
      }),
      {
        mode = "READ_WRITE"
        type = "pd-ssd"
      }
    )
  }))
  default = []
}

variable "boot_disk" {
  description = <<EOF
The boot disk for the instance.

(Optional) auto_delete - Whether the disk will be auto-deleted when the instance is deleted. Default value is true.
(Optional) initialization_params - The parameters for a new disk that will be created alongside the new instance. Either `initialization_params` or `source` must be set.
(Optional) initialization_params.image - The image from which to initialize this disk. This can be one of: the image's `self_link`, `projects/{project}/global/images/{image}`, `projects/{project}/global/images/family/{family}`, `global/images/{image}`, `global/images/family/{family}`, `family/{family}`, `{project}/{family}`, `{project}/{image}`, `{family}`, or `{image}`. If referred by family, the images names must include the family name. If they don't, use the `google_compute_image` resource instead.
(Optional) initialization_params.size - The size of the image, specified in GB. If not specified, it will inherit the size of its base image.
(Optional) initialization_params.type - The type of the disk. Default value is `pd-ssd`. Possible values are `pd-standard` and `pd-ssd`.
(Optional) source - The name or `self_link` of an existing disk (such as those managed by `google_compute_disk`), or disk image.
EOF
  type = object({
    auto_delete = optional(bool, true)
    source      = optional(string)
    initialization_params = optional(object({
      image = optional(string, "projects/debian-cloud/global/images/family/debian-11")
      size  = optional(number, 20)
      type  = optional(string, "pd-ssd")
    }))
  })
  default = {
    initialization_params = {}
  }
  nullable = false
  validation {
    condition     = !(var.boot_disk.source != null && var.boot_disk.initialization_params.image != null)
    error_message = "Only one of source or image can be specified."
  }
}

variable "description" {
  description = "A brief description of this resource."
  type        = string
  default     = null
}

variable "hostname" {
  description = "A custom hostname for the instance. Must be a fully qualified DNS name and RFC-1035-valid. Valid format is a series of labels 1-63 characters long matching the regular expression [a-z]([-a-z0-9]*[a-z0-9]), concatenated with periods. The entire hostname must not exceed 253 characters. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "labels" {
  description = "A map of user defined key/value label pairs to assign to the instance."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "machine_type" {
  description = "The machine type to create."
  type        = string
  default     = "n1-standard-1"
}

variable "metadata" {
  description = "A map of user defined key/value metadata pairs to make available from within the instance."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "name" {
  description = "A unique name for the resource, required by GCE. Changing this forces a new resource to be created."
  type        = string
}

variable "network_interfaces" {
  description = <<EOF
A list of network interfaces to attach to the instance.

(Optional) external_access - Whether to assign a public IP address to this interface. Default value is `false`.
(Optional) internal_address - The private IP address to assign to the instance. If not given, the address will be automatically assigned.
(Optional) nat_address - The IP address that will be 1:1 mapped to this interface. If not given, and external access is enabled, the address will be automatically assigned.
(Optional) network - The name or `self_link` of the network to attach this interface to. At least one of `network` or `subnetwork` must be provided. If `network` isn't provided it will be inferred from `subnetwork`.
(Optional) subnetwork - The name or `self_link` of the subnetwork to attach this interface to. At least one of `network` or `subnetwork` must be provided.
EOF
  type = list(object({
    external_access  = optional(bool, false)
    internal_address = optional(string)
    nat_address      = optional(string)
    network          = optional(string)
    subnetwork       = optional(string)
  }))
  default  = []
  nullable = false
  validation {
    condition = length([
      for i in var.network_interfaces : i if i.network != null || i.subnetwork != null
    ]) == length(var.network_interfaces)
    error_message = "At least one of `network` or `subnetwork` must be provided for each network interface."
  }
}

variable "oauth_scopes" {
  description = "A list of service scopes. Both OAuth2 URLs and gcloud short names are supported. To allow full access to all Cloud APIs, use the `cloud-platform` scope. *Note*: `allow_stopping_for_update` must be set to `true` or the instance must have a `desired_status` of `TERMINATED` in order to update this field."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "running" {
  description = "Whether the instance is running."
  type        = bool
  default     = true
}

variable "service_account_email" {
  description = "The email address of the service account to attach to the instance. If not provided, the default Compute Engine service account will be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "A list of network tags to attach to the instance."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "zone" {
  description = "The zone that the machine should be created in. If it is not provided, the provider zone is used."
  type        = string
}
