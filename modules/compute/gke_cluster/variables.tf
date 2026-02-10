variable "datapath_provider" {
  description = <<EOF
The datapath provider for the cluster. Controls packet processing and
NetworkPolicy enforcement. Cannot be changed after cluster creation without
recreating the cluster.

`ADVANCED_DATAPATH` (default) - GKE Dataplane V2. Uses eBPF via Cilium,
replacing kube-proxy and iptables. Provides built-in NetworkPolicy enforcement,
better scalability at high Service counts, and richer observability via Hubble.
Compatible with OSS Istio using the CNI plugin installation profile.

`LEGACY_DATAPATH` - Traditional iptables/kube-proxy dataplane. Use only when
compatibility with tooling that directly inspects iptables rules is required.
EOF
  type        = string
  default     = "ADVANCED_DATAPATH"
  nullable    = false
  validation {
    condition     = contains(["ADVANCED_DATAPATH", "LEGACY_DATAPATH"], var.datapath_provider)
    error_message = "`datapath_provider` must be one of `ADVANCED_DATAPATH` or `LEGACY_DATAPATH`."
  }
}

variable "description" {
  description = "A human-readable description of the cluster resource."
  type        = string
  default     = null
}

variable "enable_gcp_public_access" {
  description = "Permit access to the master endpoint from GCP's public IP ranges. Defaults to false. Takes effect only when `master_authorized_networks` is configured."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_intranode_visibility" {
  description = "Send Pod-to-Pod traffic within a node through the VPC, making it visible to VPC flow logs and subject to firewall rules. Incurs a minor performance overhead. Recommended when detailed network observability is required."
  type        = bool
  default     = false
  nullable    = false
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable the Vertical Pod Autoscaler (VPA), which automatically adjusts Pod resource requests based on historical usage. Defaults to true."
  type        = bool
  default     = true
  nullable    = false
}

variable "ip_allocation_policy" {
  description = <<EOF
VPC-native IP allocation configuration for Pod and Service networking. When null
the cluster uses routes-based networking, which is not recommended for new
clusters and is required to be set for private clusters.

(Optional) cluster_ipv4_cidr_block - CIDR range for Pod IPs. Specify either this or `cluster_secondary_range_name`, not both.
(Optional) cluster_secondary_range_name - Existing secondary range in the subnetwork to use for Pod IPs.
(Optional) services_ipv4_cidr_block - CIDR range for Service ClusterIPs. Specify either this or `services_secondary_range_name`, not both.
(Optional) services_secondary_range_name - Existing secondary range in the subnetwork to use for Service ClusterIPs.
(Optional) stack_type - `IPV4` (default) or `IPV4_IPV6` for dual-stack clusters.
EOF
  type = object({
    cluster_ipv4_cidr_block       = optional(string)
    cluster_secondary_range_name  = optional(string)
    services_ipv4_cidr_block      = optional(string)
    services_secondary_range_name = optional(string)
    stack_type                    = optional(string, "IPV4")
  })
  default = {}
  validation {
    condition     = var.ip_allocation_policy == null ? true : contains(["IPV4", "IPV4_IPV6"], var.ip_allocation_policy.stack_type)
    error_message = "ip_allocation_policy: `stack_type` must be one of `IPV4` or `IPV4_IPV6`."
  }
  validation {
    condition = var.ip_allocation_policy == null ? true : (
      !(var.ip_allocation_policy.cluster_secondary_range_name != null && var.ip_allocation_policy.cluster_ipv4_cidr_block != null) &&
      !(var.ip_allocation_policy.services_secondary_range_name != null && var.ip_allocation_policy.services_ipv4_cidr_block != null)
    )
    error_message = "ip_allocation_policy: `cluster_secondary_range_name` and `cluster_ipv4_cidr_block` are mutually exclusive, as are `services_secondary_range_name` and `services_ipv4_cidr_block`. Set the range name to use an existing secondary range, or the CIDR block to allocate a new one."
  }
}

variable "issue_client_certificate" {
  description = "Issue a client certificate to authenticate to the cluster endpoint."
  type        = bool
  default     = false
  nullable    = false
}

# Exactly one of `kubernetes_release_channel` or `kubernetes_version` must be
# set.
#
# Use `kubernetes_release_channel` for most clusters. GKE manages version
# selection and upgrades automatically within the chosen channel cadence, which
# is the recommended approach for production clusters.
#
# Use `kubernetes_version` only when pinning to a specific version is required,
# for example in a CI environment or when validating a specific patch. You are
# then responsible for keeping the version current.

variable "kubernetes_release_channel" {
  description = <<EOF
GKE release channel for automatic version management. When set, GKE selects and
upgrades the control plane version automatically. Mutually exclusive with
`kubernetes_version` — exactly one must be set.

`RAPID` - Latest releases, first to receive patches and new features. Suitable for dev/staging environments.
`REGULAR` - Releases after validation in RAPID. Recommended for most production clusters.
`STABLE` - Most conservative cadence. Suitable for business-critical workloads with strict stability requirements.
`UNSPECIFIED` - Opts out of automatic channel management. Not recommended.
EOF
  type        = string
  default     = null
  validation {
    condition     = var.kubernetes_release_channel == null ? true : contains(["RAPID", "REGULAR", "STABLE", "UNSPECIFIED"], var.kubernetes_release_channel)
    error_message = "`kubernetes_release_channel` must be one of `RAPID`, `REGULAR`, `STABLE`, or `UNSPECIFIED`."
  }
}

variable "kubernetes_version" {
  description = <<EOF
Explicit Kubernetes master version, e.g. "1.29.5-gke.1234". Mutually exclusive
with `kubernetes_release_channel` — exactly one must be set. When a release
channel is active, GKE manages the version and this variable must be null.

Use `gcloud container get-server-config --location=LOCATION` to list available
versions for a given location.
EOF
  type        = string
  default     = null
}

variable "labels" {
  description = "User defined resource labels to assign to the cluster."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "location" {
  description = "The region or zone in which to create the cluster. A region creates a regional (multi-zone) cluster; a zone creates a zonal cluster."
  type        = string
}

variable "maintenance_policy" {
  description = <<EOF
Maintenance window and exclusion configuration. When null, GKE may perform
maintenance at any time. Recommended for production clusters to constrain when
upgrades and repairs occur.

(Required) recurring_window - Time window for recurring maintenance operations.
(Required) recurring_window.end_time - Time for the (initial) recurring maintenance to end in RFC3339 format. This value is also used to calculate duration of the maintenance window.
(Required) recurring_window.start_time - Time for the (initial) recurring maintenance to start in RFC3339 format.
(Optional) recurring_window.recurrence - RRULE recurrence rule for the recurring maintenance window specified in RFC5545 format. This value is used to compute the start time of subsequent windows.

(Optional) exclusions - Exceptions to maintenance window. Non-emergency maintenance should not occur in these windows. A cluster can have up to three maintenance exclusions at a time.
(Required) exclusions.end_time - Time for the maintenance exclusion to end in RFC3339 format.
(Required) exclusions.name - Human-readable description of the maintenance exclusion. This field is for display purposes only.
(Required) exclusions.start_time - Time for the maintenance exclusion to start in RFC3339 format.
(Optional) exclusions.scope - The scope of the maintenance exclusion. Possible values are `NO_UPGRADES`, `NO_MINOR_UPGRADES`, and `NO_MINOR_OR_NODE_UPGRADES`.
EOF
  type = object({
    recurring_window = object({
      end_time   = string
      recurrence = optional(string, "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH")
      start_time = string
    })
    exclusions = optional(list(object({
      end_time   = string
      name       = string
      scope      = optional(string)
      start_time = string
    })))
  })
  default = null
  validation {
    condition = var.maintenance_policy == null ? true : (
      length(coalesce(var.maintenance_policy.exclusions, [])) <= 3
    )
    error_message = "maintenance_policy: A maximum of 3 maintenance exclusions may be configured."
  }
  validation {
    condition = var.maintenance_policy == null ? true : (
      var.maintenance_policy.exclusions == null ? true : alltrue([
        for e in var.maintenance_policy.exclusions :
        e.scope == null ? true : contains(["NO_UPGRADES", "NO_MINOR_UPGRADES", "NO_MINOR_OR_NODE_UPGRADES"], e.scope)
      ])
    )
    error_message = "maintenance_policy: `exclusions[*].scope` must be one of `NO_UPGRADES`, `NO_MINOR_UPGRADES`, or `NO_MINOR_OR_NODE_UPGRADES`."
  }
}

variable "master_authorized_networks" {
  description = <<EOF
List of CIDR blocks permitted to reach the cluster master API endpoint. When
null, access is unrestricted beyond the `enable_gcp_public_access` flag. For
private clusters this should always be set to known egress CIDRs such as office,
VPN, or CI/CD runner IP ranges.

(Required) cidr_block - The CIDR range to allow.
(Optional) display_name - A human-readable label shown in the GCP Console.
EOF
  type = list(object({
    cidr_block   = string
    display_name = optional(string)
  }))
  default = null
}

variable "name" {
  description = "Name of the cluster. Used as a prefix for the generated cluster name unless `override_name` is set."
  type        = string
  default     = null
}

variable "network" {
  description = "Name or `self_link` of the VPC network to which the cluster is connected."
  type        = string
}

variable "override_name" {
  description = "Fully qualified, authoritative name of the cluster. When set, `name` is ignored and this value is used directly as the cluster name with no suffix appended."
  type        = string
  default     = null
}

variable "prefix" {
  description = "An optional prefix prepended to `name` when generating the cluster name. Has no effect when `override_name` is set. Cannot be an empty string — use null to omit."
  type        = string
  default     = null
  validation {
    condition     = var.prefix != ""
    error_message = "`prefix` cannot be an empty string. Use null to omit the prefix."
  }
}

variable "private_cluster" {
  description = <<EOF
Private cluster configuration. When set, nodes receive only internal IP
addresses. Recommended for all production clusters. When null, the cluster is
not configured as private.

(Optional) enable_private_nodes - Assign only internal IPs to nodes. Defaults to true.
(Optional) enable_private_endpoint - Expose the master via its internal IP only, removing all public access to the API endpoint. Defaults to false.
(Optional) master_ipv4_cidr_block - A `/28` CIDR for the hosted master network. Must not overlap with any other range in the VPC. Required when `enable_private_nodes` is true.
(Optional) master_exposed_webhook_ports - TCP port ranges the GKE control plane is permitted to reach on nodes, used for admission webhook traffic. Each entry may be a single port ("8443") or a range ("1024-65535"). Defaults to ["1024-65535"], which covers all webhook controllers without requiring per-component configuration. Restrict this if your security posture requires explicit port allowlisting.
EOF
  type = object({
    enable_private_nodes         = optional(bool, true)
    enable_private_endpoint      = optional(bool, false)
    master_ipv4_cidr_block       = optional(string)
    master_exposed_webhook_ports = optional(list(string), ["1024-65535"])
  })
  default  = {}
  nullable = false
}

variable "project_id" {
  description = "The ID of the GCP project in which to create the cluster. Defaults to the provider project if not set."
  type        = string
  default     = null
}

variable "security_group" {
  description = "Google Groups security group name for Kubernetes RBAC integration. Must be in the format `gke-security-groups@yourdomain.com`."
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "Name or `self_link` of the VPC subnetwork in which the cluster nodes are launched."
  type        = string
}

variable "workload_identity_project_id" {
  description = <<EOF
The ID of the GCP project that hosts the Workload Identity pool. When set,
configures the cluster to trust Kubernetes service account tokens issued against
this pool, enabling Pods to authenticate to GCP APIs without long-lived
credentials.

This is commonly a separate, dedicated project from the one the cluster runs
in — for example, a centralised identity project shared across multiple clusters
or environments.

The workload pool is derived as `PROJECT_ID.svc.id.goog`. When null, Workload
Identity Federation is not configured on the cluster and Pods must use another
authentication mechanism.
EOF
  type        = string
  default     = null
}
