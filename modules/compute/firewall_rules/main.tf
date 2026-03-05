locals {
  # Ingress and egress rules are merged into a single map for a single
  # for_each resource. Keys are namespaced by direction to prevent collisions
  # between an ingress and an egress rule that share the same descriptor.
  _ingress_rules = {
    for name, rule in var.ingress_rules :
    "ingress-${name}" => merge(rule, {
      direction          = "INGRESS"
      destination_ranges = null
    })
  }
  _egress_rules = {
    for name, rule in var.egress_rules :
    "egress-${name}" => merge(rule, {
      direction   = "EGRESS"
      source_tags = null
      # Absent fields are merged in with null so all entries in the map share a
      # consistent shape, making attribute access safe across both directions.
      source_ranges = null
    })
  }
  firewall_rules = merge(local._ingress_rules, local._egress_rules)
}

resource "google_compute_firewall" "rules" {
  for_each    = local.firewall_rules
  description = each.value.description
  direction   = each.value.direction
  network     = var.network
  priority    = each.value.priority
  project     = var.project_id
  target_tags = each.value.target_tags

  # Always prefix rule names with the network name. The caller-supplied key
  # should be a short descriptor (e.g. "allow-ssh"), not a full rule name.
  # Direction is encoded in the key via the local namespacing above, so the
  # resulting names are e.g. "my-vpc-ingress-allow-ssh".
  name = "${var.network}-${each.key}"

  # source_ranges and source_tags apply to ingress rules only. For egress rules
  # both are set to null in locals, so these expressions are safe across both
  # directions. When neither is specified on an ingress rule, GCP requires an
  # explicit 0.0.0.0/0 to match all sources - omitting both is not permitted.
  source_tags = each.value.source_tags
  source_ranges = (
    each.value.direction == "INGRESS"
    ? coalesce(each.value.source_ranges, each.value.source_tags != null ? null : ["0.0.0.0/0"])
    : null
  )

  # destination_ranges applies to egress rules only. When not specified,
  # default to 0.0.0.0/0 to match all destinations.
  destination_ranges = (
    each.value.direction == "EGRESS"
    ? coalesce(each.value.destination_ranges, ["0.0.0.0/0"])
    : null
  )

  dynamic "allow" {
    for_each = each.value.allow ? [""] : []

    content {
      ports    = each.value.ports
      protocol = each.value.protocol
    }
  }

  dynamic "deny" {
    for_each = each.value.allow ? [] : [""]

    content {
      ports    = each.value.ports
      protocol = each.value.protocol
    }
  }

  # Firewall rule logging. The block must be absent entirely when logging is not
  # configured. When present, metadata inclusion is controlled by the
  # log_config_include_metadata field.
  dynamic "log_config" {
    for_each = each.value.log_config_include_metadata != null ? [""] : []

    content {
      metadata = each.value.log_config_include_metadata ? "INCLUDE_ALL_METADATA" : "EXCLUDE_ALL_METADATA"
    }
  }
}
