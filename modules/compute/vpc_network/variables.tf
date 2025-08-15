variable "auto_create_subnetworks" {
  description = "Whether to create a subnetwork for each compute region automatically across the `10.128.0.0/9` address range."
  type        = bool
  default     = false
}

variable "delete_default_routes_on_create" {
  description = "Whether to delete the default routes (`0.0.0.0/0`) immediately after the network is created."
  type        = bool
  default     = false
}

variable "description" {
  description = "A description of the network."
  type        = string
  default     = null
}

variable "mtu" {
  description = "The maximum transmission unit (MTU) in bytes."
  type        = number
  default     = null
}

variable "name" {
  description = "The name of the network, which must be unique within the project. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])?`."
  type        = string
}

variable "network_firewall_policy_enforcement_order" {
  description = "The order that firewall rules and firewall policies are evaluated. Default value is `AFTER_CLASSIC_FIREWALL`. Possible values are: `AFTER_CLASSIC_FIREWALL`, `BEFORE_CLASSIC_FIREWALL`."
  type        = string
  default     = "AFTER_CLASSIC_FIREWALL"
  validation {
    condition     = contains(["AFTER_CLASSIC_FIREWALL", "BEFORE_CLASSIC_FIREWALL"], var.network_firewall_policy_enforcement_order)
    error_message = "network_firewall_policy_enforcement_order must be either AFTER_CLASSIC_FIREWALL or BEFORE_CLASSIC_FIREWALL"
  }
}

variable "private_service_connect_ranges" {
  description = "A map of IP address blocks (CIDR notation) that are allowed to use Private Service Connect. If the address is not given in CIDR notation, then a prefix length of 16 is used."
  type        = map(string)
  default     = {}
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}

variable "routing_mode" {
  description = "The network-wide routing mode to use. If set to `REGIONAL`, this network's cloud routers will only advertise routes with subnetworks of this network in the same region as the router. If set to `GLOBAL`, this network's cloud routers will advertise routes with all subnetworks of this network, across regions. Possible values are: `GLOBAL`, `REGIONAL`."
  type        = string
  default     = "REGIONAL"
  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.routing_mode)
    error_message = "routing_mode must be either GLOBAL or REGIONAL"
  }
}

variable "subnets" {
  description = <<EOF
Subnets to create in the network.

(Required) ip_cidr_range - The range of internal addresses that are owned by this subnetwork. Provide this property when you create the subnetwork. For example, `10.0.0.0/8` or `192.168.0.0/16`. Ranges must be unique and non-overlapping within a network. Only IPv4 is supported.
(Required) name - The name of the resource, provided by the client when initially creating the resource. The name must be 1-63 characters long, and comply with RFC1035. Specifically, the name must be 1-63 characters long and match the regular expression `[a-z]([-a-z0-9]*[a-z0-9])?` which means the first character must be a lowercase letter, and all following characters must be a dash, lowercase letter, or digit, except the last character, which cannot be a dash.

(Optional) description - A description of the subnet.
(Optional) private_ip_google_access - When enabled, virtual machines in this subnetwork without external IP addresses can access Google APIs and services by using Private Google Access.
(Optional) purpose - The purpose of the resource. This field can be either `PRIVATE_RFC_1918`, `INTERNAL_HTTPS_LOAD_BALANCER` or `REGIONAL_MANAGED_PROXY`. Defaults to `PRIVATE_RFC_1918`.
(Optional) region - The GCP region for this subnetwork.
(Optional) role - The role of subnetwork. The value can be set to `ACTIVE` or `BACKUP`. An `ACTIVE` subnetwork is one that is currently being used. A `BACKUP` subnetwork is one that is ready to be promoted to `ACTIVE` or is currently draining. Subnetwork role must be specified when `purpose` is set to `INTERNAL_HTTPS_LOAD_BALANCER` or `REGIONAL_MANAGED_PROXY`. Possible values are: `ACTIVE`, `BACKUP`.
(Optional) stack_type - The stack type for this subnet to identify whether the IPv6 feature is enabled or not. If not specified `IPV4_ONLY` will be used. Possible values are: `IPV4_ONLY`, `IPV4_IPV6`.
(Optional) log_config - Denotes the logging options for the subnetwork flow logs. If logging is enabled logs will be exported to Stackdriver. This field cannot be set if the purpose of this subnetwork is `INTERNAL_HTTPS_LOAD_BALANCER`.
(Optional) log_config.aggregation_interval - Toggles the aggregation interval for collecting flow logs. Default value is `INTERVAL_5_SEC`. Possible values are: `INTERVAL_5_SEC`, `INTERVAL_30_SEC`, `INTERVAL_1_MIN`, `INTERVAL_5_MIN`, `INTERVAL_10_MIN`, `INTERVAL_15_MIN`.
(Optional) log_config.filter_expr - Export filter used to define which VPC flow logs should be logged, as as CEL expression. The default value is `true`, which evaluates to include everything.
(Optional) log_config.flow_sampling - The value of the field must be in [0, 1]. Default is 0.5.
(Optional) log_config.metadata - Configures whether metadata fields should be added to the reported VPC flow logs. Default value is `INCLUDE_ALL_METADATA`. Possible values are: `EXCLUDE_ALL_METADATA`, `INCLUDE_ALL_METADATA`, `CUSTOM_METADATA`.
(Optional) log_config.metadata_fields - List of metadata fields that should be added to reported logs. Can only be specified if VPC flow logs for this subnetwork is enabled and `metadata` is set to `CUSTOM_METADATA`.
(Optional) secondary_ip_ranges - An array of configurations for secondary IP ranges for virtual machine instances contained in this subnetwork.
(Optional) secondary_ip_ranges.ip_cidr_range - The range of IP addresses belonging to this subnetwork secondary range. Provide this property when you create the subnetwork. Ranges must be unique and non-overlapping with all primary and secondary IP ranges within a network. Only IPv4 is supported.
(Optional) secondary_ip_ranges.range_name - The name associated with this subnetwork secondary range, used when adding an alias IP range to a VM instance. The name must be 1-63 characters long, and comply with RFC1035. The name must be unique within the subnetwork.
EOF
  type = list(object({
    description              = optional(string)
    ip_cidr_range            = string
    name                     = string
    private_ip_google_access = optional(bool, false)
    purpose                  = optional(string, "PRIVATE_RFC_1918")
    region                   = optional(string)
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
}
