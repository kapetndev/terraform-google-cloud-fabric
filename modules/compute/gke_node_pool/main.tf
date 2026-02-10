locals {
  # When not using a verbatim name, we generate a random ID to use as the suffix
  # for the node pool name. This is to ensure that the name is unique and does
  # not conflict with any other node pool in the project. An optional prefix can
  # be added to the name, which is useful for grouping node pools.
  name   = var.name != null ? "${local.prefix}${var.name}" : null
  prefix = var.prefix != null ? "${var.prefix}-" : ""

  # The node pool name is either the caller-specified override or a generated
  # random name.
  node_pool_name = var.override_name != null ? var.override_name : random_id.node_pool_name[0].hex
}

resource "random_id" "node_pool_name" {
  count       = var.override_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_container_node_pool" "container_optimised_node_pool" {
  cluster  = var.cluster
  name     = local.node_pool_name
  project  = var.project_id
  location = var.location

  # Overrides the cluster-level max Pods setting on a per-pool basis. Affects
  # the size of the Pod CIDR slice allocated per node. Cannot be changed after
  # the node pool is created.
  max_pods_per_node = var.max_pods_per_node

  # Cluster autoscaler bounds. Always rendered — autoscaling is always active
  # and the min/max values default to sensible values when not specified.
  autoscaling {
    max_node_count = var.autoscaling.max_node_count
    min_node_count = var.autoscaling.min_node_count
  }

  # Automatic repair and upgrade. Always rendered — these are foundational
  # operational controls and should always be explicitly configured rather than
  # left to GKE defaults. Both default to true, which is strongly recommended.
  management {
    auto_repair  = var.management.auto_repair
    auto_upgrade = var.management.auto_upgrade
  }

  node_config {
    disk_size_gb    = var.node_config.disk_size
    disk_type       = var.node_config.disk_type
    image_type      = var.node_config.image_type
    labels          = var.node_config.labels
    machine_type    = var.node_config.machine_type
    service_account = var.service_account

    # Merge caller-supplied metadata with required security settings. The
    # module's keys are listed first so caller values take precedence for any
    # keys that are not security-critical.
    metadata = merge({
      # Blocks access to the GCE v1beta1 metadata API, which does not require
      # request headers and is therefore vulnerable to SSRF attacks. Any pod
      # SSRF bug would otherwise allow an attacker to reach the GKE
      # bootstrapping credentials.
      disable-legacy-endpoints = "true"

      # Surfaces the hardware RNG device to the VM, improving entropy
      # availability for cryptographic operations.
      google-compute-enable-virtio-rng = "true"
    }, var.node_config.metadata)

    # Merge caller-supplied OAuth scopes with the required baseline. The
    # baseline grants the minimum permissions for logging, monitoring, and
    # container registry access. Additional scopes are typically only needed
    # when workloads use Application Default Credentials rather than Workload
    # Identity, which is discouraged.
    oauth_scopes = setunion([
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ], var.node_config.oauth_scopes)

    # Shielded VM configuration. These options are intentionally not
    # configurable — they represent the minimum security baseline for all node
    # pools managed by this module.
    shielded_instance_config {
      # Measures the boot sequence and reports deviations to Cloud Monitoring,
      # enabling detection of boot-time tampering.
      enable_integrity_monitoring = true

      # Ensures the node boots only signed firmware and kernel, protecting
      # against bootkit and rootkit attacks.
      enable_secure_boot = true
    }

    # Workload Identity Federation for GKE. GKE_METADATA activates the node
    # metadata server, which intercepts credential requests from Pods and
    # exchanges the Pod's Kubernetes service account token for a short-lived
    # GCP access token. This means:
    #
    #   - The node service account credentials are never exposed to Pod
    #     workloads, regardless of what permissions that account holds.
    #   - Pods authenticate to GCP APIs using their own Kubernetes service
    #     account identity, bound to a GCP service account via IAM.
    #   - Access is granular per workload rather than shared across all Pods
    #     on the node.
    #
    # This is intentionally not configurable — it is a security baseline
    # requirement. Disabling it would expose the node service account token to
    # all Pods on the node via the instance metadata endpoint.
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }

  # Surge upgrade settings. Always rendered — zero-downtime upgrades require
  # explicit configuration and the defaults (max_surge=1, max_unavailable=0)
  # represent the safe baseline.
  upgrade_settings {
    max_surge       = var.upgrade_settings.max_surge
    max_unavailable = var.upgrade_settings.max_unavailable
  }

  lifecycle {
    precondition {
      condition     = (var.override_name == null) != (var.name == null)
      error_message = "name: exactly one of `name` or `override_name` must be set."
    }
  }
}
