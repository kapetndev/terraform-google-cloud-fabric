variable "description" {
  description = "A brief description of this resource."
  type        = string
  default     = null
}

variable "descriptive_name" {
  description = "The authoritative name of the cluster. Used instead of `name` variable."
  type        = string
  default     = null
}

variable "enable_intranode_visibility" {
  description = "Enable Intra-node visibility for the cluster."
  type        = bool
  default     = false
}

variable "enable_vertical_pod_autoscaling" {
  description = "Enable vertical pod autoscaling."
  type        = bool
  default     = true
}

variable "ip_allocation_policy" {
  description = <<EOF
Configuration for cluster IP allocation.

(Optional) cluster_ipv4_cidr_block - The IP address range for the cluster pod IPs. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use.
(Optional) cluster_secondary_range_name - The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. Alternatively, `cluster_ipv4_cidr_block` can be used to automatically create a GKE-managed one.
(Optional) services_ipv4_cidr_block - The IP address range of the services IPs in this cluster. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use.
(Optional) services_secondary_range_name - The name of the existing secondary range in the cluster's subnetwork to use for service `ClusterIP`s. Alternatively, `services_ipv4_cidr_block` can be used to automatically create a GKE-managed one.
(Optional) stack_type - The IP Stack Type of the cluster. Default value is `IPV4`. Possible values are `IPV4` and `IPV4_IPV6`.
EOF
  type = object({
    cluster_ipv4_cidr_block       = optional(string)
    cluster_secondary_range_name  = optional(string)
    services_ipv4_cidr_block      = optional(string)
    services_secondary_range_name = optional(string)
    stack_type                    = optional(string, "IPV4")
  })
  default = null
}

variable "issue_client_certificate" {
  description = "Issue a client certificate to authenticate to the cluster endpoint."
  type        = bool
  default     = false
}

variable "kubernetes_version" {
  description = "Kubernetes master version."
  type        = string
}

variable "kubernetes_version_release_channel" {
  description = "Kubernetes master version release channel."
  type        = string
  default     = null
  validation {
    condition = var.kubernetes_version_release_channel == null ? true : (
      contains(["RAPID", "REGULAR", "STABLE", "UNSPECIFIED"], var.kubernetes_version_release_channel)
    )
    error_message = "kubernetes_version_release_channel must be one of RAPID, REGULAR, STABLE, or UNSPECIFIED"
  }
}

variable "labels" {
  description = "User defined labels to assign to the cluster."
  type        = map(any)
  default     = {}
}

variable "location" {
  description = "Compute zone or region the cluster master nodes will sit in."
  type        = string
}

variable "maintenance_policy" {
  description = <<EOF
The maintenance policy to use for the cluster.

(Required) recurring_window - Time window for recurring maintenance operations.
(Required) recurring_window.end_time - Time for the (initial) recurring maintenance to end in RFC3339 format. This value is also used to calculte duration of the maintenance window.
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
    error_message = "exclusions must be less than or equal to 3"
  }
}

variable "name" {
  description = "Name of the cluster."
  type        = string
}

variable "network" {
  description = "Name or `self_link` of the Google Compute Engine network to which the cluster is connected."
  type        = string
}

variable "prefix" {
  description = "An optional prefix used to generate the cluster name."
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

variable "security_group" {
  description = "The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format `gke-security-groups@yourdomain.com`."
  type = string
  default = null
}

variable "subnetwork" {
  description = "Name or `self_link` of the Google Compute Engine subnetwork in which the cluster's instances are launched."
  type        = string
}
