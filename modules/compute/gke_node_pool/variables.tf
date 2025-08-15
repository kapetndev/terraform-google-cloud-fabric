variable "autoscaling" {
  description = <<EOF
Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.

(Optional) max_node_count - Maximum number of nodes per zone in the node pool.
(Optional) min_node_count - Minimum number of nodes per zone in the node pool.
EOF
  type = object({
    max_node_count = optional(number, 3)
    min_node_count = optional(number, 1)
  })
  default  = {}
  nullable = false
}

variable "cluster" {
  description = "The cluster to create the node pool for. Cluster must be present in `location` provided for clusters. May be specified in the format `projects/{{project}}/locations/{{location}}/clusters/{{cluster}}` or as just the name of the cluster."
  type        = string
}

variable "descriptive_name" {
  description = "The authoritative name of the node pool. Used instead of `name` variable."
  type        = string
  default     = null
}

variable "location" {
  description = "The location (region or zone) of the cluster. This will also be the location the node pool will be created."
  type        = string
}

variable "management" {
  description = <<EOF
Node management configuration

(Optional) auto_repair - Whether the nodes will be automatically repaired.
(Optional) auto_upgrade - Whether the nodes will be automatically upgraded.
EOF
  type = object({
    auto_repair  = optional(bool, true)
    auto_upgrade = optional(bool, true)
  })
  default  = {}
  nullable = false
}

variable "max_pods_per_node" {
  description = "Maximum number of pods per node in the node pool."
  type        = number
  default     = 110
}

variable "name" {
  description = "The name of the Google Compute node pool"
  type        = string
}

variable "node_config" {
  description = <<EOF
Parameters used in creating the node pool.

(Optional) disk_size - The size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB. Default value is 100GB.
(Optional) disk_type - The type of disk attached to each node. Default value is `pd-ssd`. Possible values are `pd-standard` and `pd-ssd`.
(Optional) image_type - The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool. Default value is `COS_CONTAINERD`.
(Optional) labels - The Kubernetes labels (key/value pairs) to be applied to each node. The kubernetes.io/ and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified.
(Optional) machine_type - The name of a Google Compute Engine machine type. Default value is `e2-medium`.
(Optional) metadata - The metadata (key/value pairs) assigned to instances in the cluster.
(Optional) oauth_scopes - The set of Google API scopes to be made available on all of the node VMs under the "default" service account.
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
}

variable "prefix" {
  description = "An optional prefix used to generate the node pool name."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "Prefix cannot be empty, please use null instead."
  }
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "upgrade_settings" {
  description = <<EOF
Node upgrade settings to change how GKE upgrades nodes.

(Optional) max_surge - The number of additional nodes that can be added to the node pool during an upgrade.
(Optional) max_unavailable - The number of nodes that can be simultaneously unavailable during an upgrade.
EOF
  type = object({
    max_surge       = optional(number, 1)
    max_unavailable = optional(number, 0)
  })
  default  = {}
  nullable = false
}
