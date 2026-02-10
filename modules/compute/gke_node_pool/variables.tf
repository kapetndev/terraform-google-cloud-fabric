variable "autoscaling" {
  description = <<EOF
Cluster autoscaler configuration. Controls the per-zone minimum and maximum node
counts. The autoscaler scales within these bounds in response to Pod scheduling
pressure.

(Optional) min_node_count - Minimum number of nodes per zone. Defaults to 1.
(Optional) max_node_count - Maximum number of nodes per zone. Defaults to 3.
EOF
  type = object({
    max_node_count = optional(number, 3)
    min_node_count = optional(number, 1)
  })
  default  = {}
  nullable = false
  validation {
    condition     = var.autoscaling.min_node_count >= 0
    error_message = "autoscaling: `min_node_count` must be 0 or greater."
  }
  validation {
    condition     = var.autoscaling.max_node_count >= 1
    error_message = "autoscaling: `max_node_count` must be 1 or greater."
  }
  validation {
    condition     = var.autoscaling.max_node_count >= var.autoscaling.min_node_count
    error_message = "autoscaling: `max_node_count` must be greater than or equal to `min_node_count`."
  }
}

variable "cluster" {
  description = "The cluster to attach the node pool to. May be specified as a short name or as the fully qualified resource ID in the format `projects/PROJECT/locations/LOCATION/clusters/CLUSTER`. The cluster must exist in the same location as the node pool."
  type        = string
  nullable    = false
}

variable "descriptive_name" {
  description = "Fully qualified, authoritative name of the node pool. When set, `name` is ignored and this value is used directly with no suffix appended."
  type        = string
  default     = null
}

variable "location" {
  description = "The region or zone of the cluster. For regional clusters, nodes are spread across all zones within the region. For zonal clusters, nodes are placed in that single zone."
  type        = string
}

variable "management" {
  description = <<EOF
Automatic node repair and upgrade configuration. Defaults to both enabled, which
is strongly recommended. Disabling auto_upgrade means you become responsible for
keeping nodes in sync with the control plane version.

(Optional) auto_repair - Automatically repair unhealthy nodes. Defaults to true.
(Optional) auto_upgrade - Automatically upgrade nodes when a new node version is available within the cluster's release channel. Defaults to true.
EOF
  type = object({
    auto_repair  = optional(bool, true)
    auto_upgrade = optional(bool, true)
  })
  default  = {}
  nullable = false
}

variable "max_pods_per_node" {
  description = "Maximum number of Pods that can be scheduled on a single node. Affects the size of the Pod CIDR allocated per node. Reducing this value allows more nodes to share a given IP range. Cannot be changed after the node pool is created."
  type        = number
  default     = 110
  nullable    = false
}

variable "name" {
  description = "Name of the node pool. Used as a prefix for the generated pool name unless `descriptive_name` is set."
  type        = string
  default     = null
}

variable "node_config" {
  description = <<EOF
Node VM configuration. All fields are optional with secure, cost-conscious
defaults.

(Optional) disk_size - Boot disk size in GB. Minimum 10GB. Defaults to 100GB.
(Optional) disk_type - Boot disk type. Must be one of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`. Defaults to `pd-ssd` for consistent IOPS.
(Optional) image_type - Node OS image. Must be one of `COS_CONTAINERD` or `UBUNTU_CONTAINERD`. Defaults to `COS_CONTAINERD` (Container-Optimised OS), which is hardened and maintained by Google. Changing this value recreates all nodes in the pool.
(Optional) labels - Kubernetes node labels applied to each node. The `kubernetes.io/` and `k8s.io/` prefixes are reserved and cannot be used.
(Optional) machine_type - Compute Engine machine type. Defaults to `e2-medium`. Choose based on your workload's CPU and memory requirements.
(Optional) metadata - GCE instance metadata key/value pairs. Merged with the module's required security metadata — caller-supplied values take precedence for non-reserved keys.
(Optional) oauth_scopes - Additional GCP API OAuth scopes granted to the node service account. Merged with the module's required baseline scopes.
EOF
  type = object({
    disk_size    = optional(number, 100)
    disk_type    = optional(string, "pd-ssd")
    image_type   = optional(string, "COS_CONTAINERD")
    labels       = optional(map(string))
    machine_type = optional(string, "e2-medium")
    metadata     = optional(map(string), {})
    oauth_scopes = optional(set(string), [])
  })
  default  = {}
  nullable = false
  validation {
    condition     = contains(["pd-standard", "pd-ssd", "pd-balanced", "pd-extreme"], var.node_config.disk_type)
    error_message = "node_config: `disk_type` must be one of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`."
  }
  validation {
    condition     = var.node_config.disk_size >= 10
    error_message = "node_config: `disk_size` must be at least 10GB."
  }
  validation {
    condition     = contains(["COS_CONTAINERD", "UBUNTU_CONTAINERD"], var.node_config.image_type)
    error_message = "node_config: `image_type` must be one of `COS_CONTAINERD` or `UBUNTU_CONTAINERD`."
  }
}

variable "prefix" {
  description = "An optional prefix prepended to `name` when generating the node pool name. Has no effect when `descriptive_name` is set. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "project_id" {
  description = "The ID of the GCP project in which to create the node pool. Defaults to the provider project if not set."
  type        = string
  default     = null
}

variable "service_account" {
  description = <<EOF
The email of the GCP service account to assign to the nodes in this pool. The
nodes use this identity for GCP API calls such as pulling images from Artifact
Registry, writing logs, and writing metrics.

A dedicated, minimal service account should always be created and provided
here. Do not use the Compute Engine default service account
(PROJECT_NUMBER-compute@developer.gserviceaccount.com) — it has project-wide
editor permissions and represents a significant privilege escalation risk if a
node is compromised.

The service account must be granted the following roles at minimum:
  - roles/logging.logWriter
  - roles/monitoring.metricWriter
  - roles/monitoring.viewer
  - roles/artifactregistry.reader  (or roles/storage.objectViewer for GCR)

When Workload Identity Federation is active (`workload_metadata_config =
GKE_METADATA`, which is the default), the node service account credentials are
not accessible to Pod workloads. Pods authenticate to GCP via their Kubernetes
service account tokens instead.
EOF
  type        = string
}

variable "upgrade_settings" {
  description = <<EOF
Controls how GKE replaces nodes during upgrades. The default configuration adds
one surge node before taking a node offline, ensuring zero downtime.

(Optional) max_surge - Number of additional nodes provisioned during an upgrade. Higher values speed up upgrades at the cost of temporary extra capacity. Defaults to 1.
(Optional) max_unavailable - Number of nodes that may be simultaneously unavailable during an upgrade. Setting this above 0 risks disrupting workloads without Pod Disruption Budgets. Defaults to 0.
EOF
  type = object({
    max_surge       = optional(number, 1)
    max_unavailable = optional(number, 0)
  })
  default  = {}
  nullable = false
  validation {
    condition     = var.upgrade_settings.max_surge + var.upgrade_settings.max_unavailable > 0
    error_message = "upgrade_settings: At least one of `max_surge` or `max_unavailable` must be greater than 0."
  }
}
