locals {
  # When not using a verbatim name, we generate a random ID to use as the suffix
  # for the instance name. This is to ensure that the name is unique and does
  # not conflict with any other instances in the project. An optional prefix can
  # be added to the name, which is useful for grouping instances.
  name   = var.name != null ? "${local.prefix}${var.name}" : null
  prefix = var.prefix != null ? "${var.prefix}-" : ""

  # The instance name is either the caller-specified override or a generated
  # random name.
  instance_name = var.override_name != null ? var.override_name : random_id.instance_name[0].hex

  # Convert the attached_disks list to a map keyed by source for use with
  # for_each. Source is the stable external identity of the disk, and must be
  # unique across all attachments on a given instance.
  attached_disks = {
    for disk in var.attached_disks :
    disk.source => disk
  }

  # Convert the managed_disks list to a map keyed by name for use with
  # for_each. Names are required to be unique by GCE, so this is safe.
  managed_disks = {
    for disk in var.managed_disks :
    disk.name => disk
  }
}

resource "google_compute_disk" "persistent_disks" {
  for_each    = local.managed_disks
  description = each.value.description
  image       = each.value.source_type == "image" ? each.value.source : null
  name        = each.value.name
  project     = var.project_id
  size        = each.value.size
  snapshot    = each.value.source_type == "snapshot" ? each.value.source : null
  type        = each.value.options.type
  zone        = var.zone

  labels = merge(var.labels, {
    disk_name = each.value.name,
    disk_type = each.value.options.type,
  })

  # Prevent accidental destruction of data disks. This lifecycle rule cannot be
  # driven by a variable — prevent_destroy must be a literal value known at
  # parse time, which is a Terraform language constraint. To destroy a managed
  # disk, remove it from the managed_disks variable and apply before running
  # destroy, or manage the disk outside this module.
  lifecycle {
    prevent_destroy = true
  }
}

resource "random_id" "instance_name" {
  count       = var.override_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_compute_instance" "instance" {
  description    = var.description
  desired_status = var.running ? "RUNNING" : "TERMINATED"
  hostname       = var.hostname
  labels         = var.labels
  machine_type   = var.machine_type
  name           = local.instance_name
  project        = var.project_id
  tags           = var.tags
  zone           = var.zone

  # Allows Terraform to stop the instance before applying changes that require a
  # restart, such as service account or machine type updates.
  allow_stopping_for_update = true

  # Externally managed disks are referenced directly by their source (name or
  # self_link). This module does not control their lifecycle.
  dynamic "attached_disk" {
    for_each = local.attached_disks
    iterator = disk

    content {
      device_name = coalesce(disk.value.device_name, disk.value.source)
      mode        = disk.value.mode
      source      = disk.value.source
    }
  }

  # Managed disks are referenced by the name of the created resource.
  dynamic "attached_disk" {
    for_each = local.managed_disks
    iterator = disk

    content {
      device_name = coalesce(disk.value.device_name, disk.value.name)
      mode        = disk.value.options.mode
      source      = google_compute_disk.persistent_disks[disk.key].name
    }
  }

  boot_disk {
    auto_delete = var.boot_disk.auto_delete
    source      = var.boot_disk.source

    # Only rendered when creating a new disk alongside the instance. Must be
    # absent when source references an existing disk, as the two are mutually
    # exclusive on the GCP API.
    dynamic "initialize_params" {
      for_each = var.boot_disk.initialization_params != null ? [""] : []

      content {
        image = var.boot_disk.initialization_params.image
        size  = var.boot_disk.initialization_params.size
        type  = var.boot_disk.initialization_params.type
      }
    }
  }

  # Merge caller-supplied metadata with required security settings. The module's
  # key is listed first so caller values take precedence for any keys that are
  # not security-critical.
  metadata = merge({
    # Blocks the ability to add SSH keys via the metadata API, which is a common
    # persistence mechanism for attackers who have compromised a VM to maintain
    # access. SSH keys should be managed via OS Login or a similar mechanism
    # instead.
    block-project-ssh-keys = "true"
  }, var.metadata)

  dynamic "network_interface" {
    for_each = var.network_interfaces
    iterator = interface

    content {
      network_ip = interface.value.internal_address
      network    = interface.value.network
      subnetwork = interface.value.subnetwork

      # Only rendered when a public IP is required. Absent by default — most
      # instances in private networks should egress via Cloud NAT rather than
      # carrying a public IP directly.
      dynamic "access_config" {
        for_each = interface.value.external_access ? [""] : []

        content {
          nat_ip = interface.value.nat_address
        }
      }
    }
  }

  service_account {
    email = var.service_account

    # Merge caller-supplied OAuth scopes with the required baseline. The
    # baseline grants the minimum permissions for logging, monitoring, and
    # container registry access. Additional scopes are typically only needed
    # when workloads use Application Default Credentials rather than Workload
    # Identity, which is discouraged.
    scopes = setunion([
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ], var.oauth_scopes)
  }

  # Shielded VM configuration. These options are intentionally not
  # configurable — they represent the minimum security baseline for all
  # instances managed by this module.
  shielded_instance_config {
    # Measures the boot sequence and reports deviations to Cloud Monitoring,
    # enabling detection of boot-time tampering.
    enable_integrity_monitoring = true

    # Ensures the node boots only signed firmware and kernel, protecting against
    # bootkit and rootkit attacks.
    enable_secure_boot = true
  }

  lifecycle {
    precondition {
      condition     = (var.override_name == null) != (var.name == null)
      error_message = "name: exactly one of `name` or `override_name` must be set."
    }
    precondition {
      condition     = var.boot_disk.source != null || var.boot_disk.initialization_params != null
      error_message = "boot_disk: at least one of `source` or `initialization_params` must be set."
    }
    precondition {
      condition     = !(var.boot_disk.source != null && var.boot_disk.initialization_params != null)
      error_message = "boot_disk: `source` and `initialization_params` are mutually exclusive. Set one or the other, not both."
    }
  }
}
