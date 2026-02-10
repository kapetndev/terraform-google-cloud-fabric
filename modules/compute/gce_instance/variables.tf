variable "attached_disks" {
  description = <<EOF
Existing persistent disks to attach to the instance. These disks are managed
outside this module — only the attachment is controlled here. The disk resource
itself is not created, modified, or destroyed by this module.

(Required) source - Name or `self_link` of the existing disk to attach.

(Optional) device_name - Name under which the disk is exposed inside the instance at `/dev/disk/by-id/google-DEVICE_NAME`. Defaults to the value of `source`.
(Optional) mode - Attachment mode. `READ_WRITE` (default) or `READ_ONLY`.
EOF
  type = list(object({
    device_name = optional(string)
    mode        = optional(string, "READ_WRITE")
    source      = string
  }))
  default  = []
  nullable = false
  validation {
    condition = alltrue([
      for d in var.attached_disks :
      contains(["READ_WRITE", "READ_ONLY"], d.mode)
    ])
    error_message = "attached_disks: `mode` must be one of `READ_WRITE` or `READ_ONLY`."
  }
}

variable "boot_disk" {
  description = <<EOF
Boot disk configuration. Exactly one of initialization_params or source must be
set.

(Optional) auto_delete - Whether to delete the boot disk when the instance is deleted. Defaults to true.
(Optional) source - The name or `self_link` of an existing disk to attach as the boot disk. Mutually exclusive with `initialization_params`.

(Optional) initialization_params - Parameters for a new disk created with the instance. Mutually exclusive with `source`.
(Optional) initialization_params.image - The image from which to initialise the disk. Accepts `self_link`, `projects/PROJECT/global/images/IMAGE`, `family/FAMILY`, or short forms. Defaults to the latest Debian 12 (Bookworm) image.
(Optional) initialization_params.size - Disk size in GB. Defaults to 20.
(Optional) initialization_params.type - Disk type. One of pd-standard, pd-ssd, pd-balanced, or pd-extreme. Defaults to pd-ssd.
EOF
  type = object({
    auto_delete = optional(bool, true)
    source      = optional(string)
    initialization_params = optional(object({
      image = optional(string, "projects/debian-cloud/global/images/family/debian-12")
      size  = optional(number, 20)
      type  = optional(string, "pd-ssd")
    }))
  })
  default = {
    initialization_params = {}
  }
  nullable = false
  validation {
    condition = !(
      var.boot_disk.source != null && var.boot_disk.initialization_params != null
    )
    error_message = "boot_disk: `source` and `initialization_params` are mutually exclusive. Set one or the other, not both."
  }
  validation {
    condition = (
      var.boot_disk.source != null || var.boot_disk.initialization_params != null
    )
    error_message = "boot_disk: at least one of `source` or `initialization_params` must be set."
  }
  validation {
    condition = (
      var.boot_disk.initialization_params == null ? true :
      contains(["pd-standard", "pd-ssd", "pd-balanced", "pd-extreme"], var.boot_disk.initialization_params.type)
    )
    error_message = "boot_disk: `initialization_params.type` must be one of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`."
  }
}

variable "description" {
  description = "A human-readable description of the instance resource."
  type        = string
  default     = null
}

variable "hostname" {
  description = "A custom hostname for the instance. Must be a fully qualified DNS name and RFC-1035-valid — a series of labels 1-63 characters long matching `[a-z]([-a-z0-9]*[a-z0-9])`, joined with periods, not exceeding 253 characters in total. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "labels" {
  description = "User defined resource labels to assign to the instance."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "machine_type" {
  description = "The Compute Engine machine type for the instance, e.g. `e2-medium`, `n2-standard-2`."
  type        = string
  default     = "e2-medium"
  nullable    = false
}

variable "managed_disks" {
  description = <<EOF
Persistent disks to create and attach to the instance. This module owns the
lifecycle of these disks — they are created as `google_compute_disk` resources
with `prevent_destroy = true` to guard against accidental data loss.

To destroy a managed disk, first remove it from this variable and apply, then
run destroy, or manage the disk outside this module.

(Required) name - Unique name for the disk resource, required by GCE.
(Required) size - Disk size in GB.

(Optional) description - Human-readable description of the disk.
(Optional) device_name - Name under which the disk is exposed inside the instance at `/dev/disk/by-id/google-DEVICE_NAME`. Defaults to the disk name.
(Optional) source - Name or `self_link` of the image or snapshot to initialise the disk from. Required when `source_type` is `image` or `snapshot`. Omit to create a blank disk.

(Optional) source_type - How to initialise the disk. Defaults to `blank`. One of:
  `blank`    - Create an empty disk. `source` must not be set.
  `image`    - Initialise the disk from the image named in `source`.
  `snapshot` - Restore the disk from the snapshot named in `source`.

(Optional) options - Disk options.
(Optional) options.mode - Attachment mode. `READ_WRITE` (default) or `READ_ONLY`.
(Optional) options.type - Disk type. One of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`. Defaults to `pd-ssd`.
EOF
  type = list(object({
    description = optional(string)
    device_name = optional(string)
    name        = string
    size        = number
    source      = optional(string)
    source_type = optional(string, "blank")
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
  default  = []
  nullable = false
  validation {
    condition = alltrue([
      for d in var.managed_disks :
      contains(["blank", "image", "snapshot"], d.source_type)
    ])
    error_message = "managed_disks: `source_type` must be one of `blank`, `image`, or `snapshot`."
  }
  validation {
    condition = alltrue([
      for d in var.managed_disks :
      contains(["image", "snapshot"], d.source_type) ? d.source != null : true
    ])
    error_message = "managed_disks: `source` must be set when `source_type` is `image` or `snapshot`."
  }
  validation {
    condition = alltrue([
      for d in var.managed_disks :
      d.source_type == "blank" ? d.source == null : true
    ])
    error_message = "managed_disks: `source` must not be set when `source_type` is `blank`."
  }
  validation {
    condition = alltrue([
      for d in var.managed_disks :
      contains(["pd-standard", "pd-ssd", "pd-balanced", "pd-extreme"], d.options.type)
    ])
    error_message = "managed_disks: `options.type` must be one of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`."
  }
  validation {
    condition = alltrue([
      for d in var.managed_disks :
      contains(["READ_WRITE", "READ_ONLY"], d.options.mode)
    ])
    error_message = "managed_disks: `options.mode` must be one of `READ_WRITE` or `READ_ONLY`."
  }
}

variable "metadata" {
  description = "User-defined key/value metadata pairs to make available from within the instance. Merged with the module's required security metadata — caller-supplied values take precedence for non-reserved keys."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "name" {
  description = "Name of the instance. Used as a prefix for the generated instance name unless `override_name` is set."
  type        = string
  default     = null
}

variable "network_interfaces" {
  description = <<EOF
Network interfaces to attach to the instance. At least one interface must be
provided. For each interface, at least one of network or subnetwork must be set.

(Optional) external_access - Whether to assign a public IP (NAT) to this interface. Defaults to false. Avoid enabling this on instances in private clusters or subnets without a Cloud NAT gateway.
(Optional) internal_address - Static private IP address. If not set, GCP assigns one automatically.
(Optional) nat_address - Static external IP to use when `external_access` is true. If not set, an ephemeral IP is assigned automatically.
(Optional) network - Name or `self_link` of the VPC network. If not provided, inferred from subnetwork.
(Optional) subnetwork - Name or `self_link` of the subnetwork. If not provided, inferred from network.
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
    condition     = length(var.network_interfaces) > 0
    error_message = "network_interfaces: At least one network interface must be provided."
  }
  validation {
    condition = alltrue([
      for i in var.network_interfaces : i.network != null || i.subnetwork != null
    ])
    error_message = "network_interfaces: Each network interface must have at least one of `network` or `subnetwork` set."
  }
}

variable "oauth_scopes" {
  description = "Additional GCP API OAuth scopes granted to the instance service account, merged with the module's required baseline scopes. Additional scopes are typically only needed when workloads use Application Default Credentials rather than Workload Identity, which is discouraged."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "override_name" {
  description = "Fully qualified, authoritative name of the instance. When set, `name` is ignored and this value is used directly as the instance name with no suffix appended."
  type        = string
  default     = null
}

variable "prefix" {
  description = "An optional prefix prepended to `name` when generating the instance name. Has no effect when `override_name` is set. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "project_id" {
  description = "The ID of the GCP project in which to create the instance. Defaults to the provider project if not set."
  type        = string
  default     = null
}

variable "running" {
  description = "Whether the instance should be running. When false, the instance is kept in a `TERMINATED` state. Useful for cost management in non-production environments."
  type        = bool
  default     = true
  nullable    = false
}

variable "service_account" {
  description = <<EOF
The email of the GCP service account to assign to the instance.

A dedicated, minimal service account should always be created and provided
here. Do not use the Compute Engine default service account
(PROJECT_NUMBER-compute@developer.gserviceaccount.com) — it has project-wide
editor permissions and represents a significant privilege escalation risk if an
instance is compromised.
EOF
  type        = string
}

variable "tags" {
  description = "Network tags to attach to the instance. Used to identify the instance for applicable firewall rules and network routes."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "zone" {
  description = "The zone in which to create the instance. If not provided, the provider zone is used."
  type        = string
}
