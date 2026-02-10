variable "auto_create_subnetworks" {
  description = "When true, GCP automatically creates a subnetwork in each region across the `10.128.0.0/9` address range. Defaults to false — subnets should be managed explicitly via the subnets variable."
  type        = bool
  default     = false
}

variable "delete_default_routes_on_create" {
  description = "When true, the default internet route (`0.0.0.0/0`) is deleted immediately after the network is created. Recommended when all egress should be controlled explicitly via Cloud NAT or Cloud Router rather than permitting arbitrary internet egress."
  type        = bool
  default     = false
}

variable "description" {
  description = "A human-readable description of the network resource."
  type        = string
  default     = null
}

variable "enable_ula_internal_ipv6" {
  description = "Enable Unique Local Address (ULA) internal IPv6 on the network. When enabled, a `/48` ULA range is allocated from Google's `fd20::/20` prefix and assigned to the network."
  type        = bool
  default     = false
}

variable "internal_ipv6_range" {
  description = "A specific `/48` ULA IPv6 range from Google's `fd20::/20` prefix to assign to the network. Only valid when `enable_ula_internal_ipv6` is true. When null, GCP assigns a range automatically."
  type        = string
  default     = null
}

variable "mtu" {
  description = "Maximum transmission unit in bytes. Must be between 1300 and 8896. Use 1500 for standard Ethernet, or up to 8896 for Jumbo Frames on supported machine types. When null, GCP uses its default of 1460."
  type        = number
  default     = null
  validation {
    condition     = var.mtu == null ? true : (var.mtu >= 1300 && var.mtu <= 8896)
    error_message = "mtu must be between 1300 and 8896."
  }
}

variable "name" {
  description = "The name of the VPC network. Must be 1-63 characters long, lowercase, and match `[a-z]([-a-z0-9]*[a-z0-9])?`. Must be unique within the project."
  type        = string
}

variable "network_firewall_policy_enforcement_order" {
  description = "Evaluation order of firewall policies relative to classic (per-network) firewall rules. `AFTER_CLASSIC_FIREWALL` evaluates network firewall policies after classic rules; `BEFORE_CLASSIC_FIREWALL` evaluates them first."
  type        = string
  default     = "AFTER_CLASSIC_FIREWALL"
  validation {
    condition     = contains(["AFTER_CLASSIC_FIREWALL", "BEFORE_CLASSIC_FIREWALL"], var.network_firewall_policy_enforcement_order)
    error_message = "network_firewall_policy_enforcement_order must be one of `AFTER_CLASSIC_FIREWALL` or `BEFORE_CLASSIC_FIREWALL`."
  }
}

variable "private_services_access_ranges" {
  description = <<EOF
IP address ranges (in CIDR notation) to reserve for Private Services Access.
Private Services Access allocates these ranges in your VPC and peers them with
Google's service producer network via `servicenetworking.googleapis.com`,
enabling private connectivity to managed services such as Cloud SQL,
Memorystore, and AlloyDB without traffic traversing the public internet.

Each entry is a map of name => CIDR, e.g.:
  { "google-managed-services" = "10.100.0.0/16" }

If the prefix length is omitted from the CIDR, `/16` is assumed.

Note: this is distinct from Private Service Connect, which uses forwarding rules
and service attachments to reach Google APIs by private IP.
EOF
  type        = map(string)
  default     = {}
}

variable "project_id" {
  description = "The ID of the GCP project in which to create the network. Defaults to the provider project if not set."
  type        = string
  default     = null
}

variable "routing_mode" {
  description = "Network-wide routing mode. `REGIONAL` advertises only routes within the same region as the Cloud Router. `GLOBAL` advertises routes across all regions, required for global load balancing and multi-region topologies."
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.routing_mode)
    error_message = "routing_mode must be one of `GLOBAL` or `REGIONAL`."
  }
}

variable "subnets" {
  description = <<EOF
Subnets to create within the network. Multiple subnets may share a name across
different regions - the resource key is region/name to ensure uniqueness.

(Required) name - Subnet name. Must be 1-63 characters, lowercase, matching `[a-z]([-a-z0-9]*[a-z0-9])?`.
(Required) ip_cidr_range - Primary IPv4 CIDR range. Must be unique and non-overlapping within the network.
(Required) region - GCP region in which to create the subnet.

(Optional) description - Human-readable description.
(Optional) private_ip_google_access - Allow VMs without external IPs to reach Google APIs via internal routing. Defaults to true — required for GKE nodes, Cloud SQL clients, and any workload that calls Google APIs without a public IP or Cloud NAT.
(Optional) purpose - Subnet purpose. One of PRIVATE, REGIONAL_MANAGED_PROXY, GLOBAL_MANAGED_PROXY, PRIVATE_SERVICE_CONNECT, PEER_MIGRATION, or PRIVATE_NAT. Defaults to PRIVATE.
(Optional) role - ACTIVE or BACKUP. Required when purpose is REGIONAL_MANAGED_PROXY or GLOBAL_MANAGED_PROXY.
(Optional) stack_type - IPV4_ONLY (default) or IPV4_IPV6.
(Optional) ipv6_access_type - INTERNAL or EXTERNAL. Only valid when stack_type is IPV4_IPV6.

(Optional) log_config - Enable VPC flow log export for this subnet. When null, flow logging is disabled. Cannot be set when purpose is INTERNAL_HTTPS_LOAD_BALANCER.
  (Optional) aggregation_interval - Log aggregation window. One of INTERVAL_5_SEC (default), INTERVAL_30_SEC, INTERVAL_1_MIN, INTERVAL_5_MIN, INTERVAL_10_MIN, or INTERVAL_15_MIN.
  (Optional) filter_expr - CEL expression to filter exported logs.  Defaults to "true" (export all).
  (Optional) flow_sampling - Fraction of flow logs to export, between 0 and 1. Defaults to 0.5.
  (Optional) metadata - Metadata fields to include. One of INCLUDE_ALL_METADATA (default), EXCLUDE_ALL_METADATA, or CUSTOM_METADATA.
  (Optional) metadata_fields - Specific metadata fields to export. Only valid when metadata is CUSTOM_METADATA.

(Optional) secondary_ip_ranges - Additional IP ranges for alias IPs, e.g.  for GKE Pod and Service CIDRs. Each range must be unique and non-overlapping within the network.
  (Required) range_name - Name for the secondary range.
  (Required) ip_cidr_range - CIDR range for the secondary range.
EOF
  type = list(object({
    description              = optional(string)
    ip_cidr_range            = string
    ipv6_access_type         = optional(string)
    name                     = string
    private_ip_google_access = optional(bool, true)
    purpose                  = optional(string, "PRIVATE")
    region                   = string
    role                     = optional(string)
    stack_type               = optional(string, "IPV4_ONLY")
    log_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_SEC")
      filter_expr          = optional(string, "true")
      flow_sampling        = optional(number, 0.5)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      metadata_fields      = optional(list(string))
    }))
    secondary_ip_ranges = optional(list(object({
      ip_cidr_range = string
      range_name    = string
    })), [])
  }))
  default  = []
  nullable = false
  validation {
    condition = alltrue([
      for s in var.subnets :
      s.purpose == null ? true : contains(
        ["PRIVATE", "REGIONAL_MANAGED_PROXY", "GLOBAL_MANAGED_PROXY", "PRIVATE_SERVICE_CONNECT", "PEER_MIGRATION", "PRIVATE_NAT"],
        s.purpose
      )
    ])
    error_message = "subnets: `purpose` must be one of `PRIVATE`, `REGIONAL_MANAGED_PROXY`, `GLOBAL_MANAGED_PROXY`, `PRIVATE_SERVICE_CONNECT`, `PEER_MIGRATION`, or `PRIVATE_NAT`."
  }
  validation {
    condition = alltrue([
      for s in var.subnets :
      s.stack_type == null ? true : contains(["IPV4_ONLY", "IPV4_IPV6"], s.stack_type)
    ])
    error_message = "subnets: `stack_type` must be one of `IPV4_ONLY` or `IPV4_IPV6`."
  }
  validation {
    condition = alltrue([
      for s in var.subnets :
      s.log_config == null ? true : contains(
        ["INTERVAL_5_SEC", "INTERVAL_30_SEC", "INTERVAL_1_MIN", "INTERVAL_5_MIN", "INTERVAL_10_MIN", "INTERVAL_15_MIN"],
        s.log_config.aggregation_interval
      )
    ])
    error_message = "subnets: `log_config.aggregation_interval` must be one of `INTERVAL_5_SEC`, `INTERVAL_30_SEC`, `INTERVAL_1_MIN`, `INTERVAL_5_MIN`, `INTERVAL_10_MIN`, or `INTERVAL_15_MIN`."
  }
  validation {
    condition = alltrue([
      for s in var.subnets :
      s.log_config == null ? true : contains(
        ["INCLUDE_ALL_METADATA", "EXCLUDE_ALL_METADATA", "CUSTOM_METADATA"],
        s.log_config.metadata
      )
    ])
    error_message = "subnets: `log_config.metadata` must be one of `INCLUDE_ALL_METADATA`, `EXCLUDE_ALL_METADATA`, or `CUSTOM_METADATA`."
  }
}

