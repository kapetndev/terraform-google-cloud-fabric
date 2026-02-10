variable "egress_rules" {
  description = <<EOF
Egress firewall rules to apply to the VPC network, keyed by a short descriptive
name. Each key is prefixed with the network name when creating the GCP resource,
so keys should be brief descriptors rather than full rule names
(e.g. "deny-internal" rather than "my-vpc-deny-internal").

(Required) allow - Whether to allow (true) or deny (false) matching traffic.
(Required) protocol - IP protocol. One of `tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`, or an IP protocol number.

(Optional) description - Human-readable description of the rule.
(Optional) priority - Rule priority between 0 and 65535. Lower values take precedence. Defaults to 1000. DENY rules take precedence over ALLOW rules at equal priority.
(Optional) ports - TCP/UDP ports or ranges the rule applies to, e.g. ["443", "8080-8090"]. Omit to match all ports.
(Optional) destination_ranges - Destination CIDR ranges the rule applies to. When null, defaults to `0.0.0.0/0`.
(Optional) target_tags - Network tags identifying the source instances the rule applies to. When null the rule applies to all instances in the network.
(Optional) log_config_include_metadata - When set, enables firewall rule logging. true includes all metadata; false excludes it.
EOF
  type = map(object({
    allow                       = bool
    description                 = optional(string)
    destination_ranges          = optional(set(string))
    log_config_include_metadata = optional(bool)
    ports                       = optional(set(string))
    priority                    = optional(number, 1000)
    protocol                    = string
    target_tags                 = optional(set(string))
  }))
  default  = {}
  nullable = false
  validation {
    condition = alltrue([
      for r in values(var.egress_rules) : r.priority >= 0 && r.priority <= 65535
    ])
    error_message = "egress_rules: all `priority` values must be between 0 and 65535."
  }
}

variable "ingress_rules" {
  description = <<EOF
Ingress firewall rules to apply to the VPC network, keyed by a short descriptive
name. Each key is prefixed with the network name when creating the GCP resource,
so keys should be brief descriptors rather than full rule names
(e.g. "allow-ssh" rather than "my-vpc-allow-ssh").

(Required) allow - Whether to allow (true) or deny (false) matching traffic.
(Required) protocol - IP protocol. One of `tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`, or an IP protocol number.

(Optional) description - Human-readable description of the rule.
(Optional) priority - Rule priority between 0 and 65535. Lower values take precedence. Defaults to 1000. DENY rules take precedence over ALLOW rules at equal priority.
(Optional) ports - TCP/UDP ports or ranges the rule applies to, e.g. ["80", "8080-8090"]. Omit to match all ports.
(Optional) source_ranges - Source CIDR ranges the rule applies to. When null and source_tags is also null, defaults to `0.0.0.0/0`.
(Optional) source_tags - Source network tags the rule applies to. Cannot be used to control traffic to an instance's external IP address.
(Optional) target_tags - Network tags identifying the target instances. When null the rule applies to all instances in the network.
(Optional) log_config_include_metadata - When set, enables firewall rule logging. true includes all metadata; false excludes it.
EOF
  type = map(object({
    allow                       = bool
    description                 = optional(string)
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
  validation {
    condition = alltrue([
      for r in values(var.ingress_rules) : r.priority >= 0 && r.priority <= 65535
    ])
    error_message = "ingress_rules: all `priority` values must be between 0 and 65535."
  }
}

variable "network" {
  description = "Name or `self_link` of the VPC network to attach the firewall rules to."
  type        = string
  nullable    = false
}

variable "project_id" {
  description = "The ID of the GCP project in which to create the firewall rules. Defaults to the provider project if not set."
  type        = string
  default     = null
}
