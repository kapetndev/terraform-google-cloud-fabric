variable "default_rules" {
  description = <<EOF
Default firewall rules to be applied to the VPC network.

(Optional) http_ranges - A list of source CIDR ranges that are allowed to make HTTP requests to instances with matching tags. An empty list will disable the rule.
(Optional) http_tags - A list of instance tags which are allowed to receive HTTP requests from sources with matching ranges.
(Optional) https_ranges - A list of source CIDR ranges that are allowed to make HTTPS requests to instances with matching tags. An empty list will disable the rule.
(Optional) https_tags - A list of instance tags which are allowed to receive HTTPS requests from sources with matching ranges.
(Optional) ssh_ranges - A list of source CIDR ranges that are allowed to make SSH requests to instances with matching tags. An empty list will disable the rule.
(Optional) ssh_tags - A list of instance tags which are allowed to receive SSH requests from sources with matching ranges.
EOF
  type = object({
    http_ranges  = optional(set(string), [])
    http_tags    = optional(set(string), ["http-server"])
    https_ranges = optional(set(string), [])
    https_tags   = optional(set(string), ["https-server"])
    ssh_ranges   = optional(set(string), [])
    ssh_tags     = optional(set(string), ["ssh-server"])
  })
  default  = {}
  nullable = false
}

variable "egress_rules" {
  description = <<EOF
A list of egress firewall rules specified by the user to be applied to the VPC network.

(Required) protocol - The IP protocol to which this rule applies. This value can either be one of the following well known protocol strings (`tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`), or the IP protocol number.

(Optional) allow - The firewall rule action. Setting this to `true` will allow all traffic matching the rule; otherwise this will deny all traffic. Default value is `false`.
(Optional) description - A description og the firewall rule.
(Optional) destination_ranges - If destination ranges are specified, the firewall will apply only to traffic that has destination IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.
(Optional) log_config_iinclude_metadata - Whether to include or exclude metadata for firewall logs.
(Optional) ports - An optional list of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. Each entry must be either an integer or a range. If not specified, this rule applies to connections through any port.
(Optional) priority - A value between `0` and `65535` that specifies the priority of the rule. Defaults to `1000`. Relative priorities determine precedence of conflicting rules. Lower value of priority implies higher precedence. DENY rules take precedence over ALLOW rules having equal priority.
(Optional) source_ranges - If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.
(Optional) source_tags - If source tags are specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags. Source tags cannot be used to control traffic to an instance's external IP address.
(Optional) target_tags - A list of instance tags indicating sets of instances located in the network that may make network connections. If no target tags are specified, the firewall rule applies to all instances on the specified network.
EOF
  type = map(object({
    allow                       = optional(bool, false)
    description                 = optional(string)
    destination_ranges          = optional(set(string))
    log_config_include_metadata = optional(bool)
    ports                       = optional(set(string))
    priority                    = optional(number, 1000)
    protocol                    = string
    source_ranges               = optional(set(string))
    source_tags                 = optional(set(string))
    target_tags                 = optional(set(string))
  }))
  default  = {}
  nullable = false
}

variable "ingress_rules" {
  description = <<EOF
A list of ingress firewall rules specified by the user to be applied to the VPC network.

(Required) protocol - The IP protocol to which this rule applies. This value can either be one of the following well known protocol strings (`tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`), or the IP protocol number.

(Optional) allow - The firewall rule action. Setting this to `true` will allow all traffic matching the rule; otherwise this will deny all traffic. Default value is `false`.
(Optional) description - A description og the firewall rule.
(Optional) destination_ranges - If destination ranges are specified, the firewall will apply only to traffic that has destination IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.
(Optional) log_config_iinclude_metadata - Whether to include or exclude metadata for firewall logs.
(Optional) ports - An optional list of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. Each entry must be either an integer or a range. If not specified, this rule applies to connections through any port.
(Optional) priority - A value between `0` and `65535` that specifies the priority of the rule. Defaults to `1000`. Relative priorities determine precedence of conflicting rules. Lower value of priority implies higher precedence. DENY rules take precedence over ALLOW rules having equal priority.
(Optional) source_ranges - If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.
(Optional) source_tags - If source tags are specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags. Source tags cannot be used to control traffic to an instance's external IP address.
(Optional) target_tags - A list of instance tags indicating sets of instances located in the network that may make network connections. If no target tags are specified, the firewall rule applies to all instances on the specified network.
EOF
  type = map(object({
    allow                       = optional(bool, false)
    description                 = optional(string)
    destination_ranges          = optional(set(string))
    log_config_include_metadata = optional(bool)
    ports                       = optional(set(string))
    priority                    = optional(number, 1000)
    protocol                    = string
    source_ranges               = optional(set(string))
    source_tags                 = optional(set(string))
    target_tags                 = optional(set(string))
  }))
  default  = {}
  nullable = false
}

variable "network" {
  description = "The name of `self_link` of the the network to attach the firewall rules to."
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs. If it is not provided, the provider project is used."
  type        = string
  default     = null
}
