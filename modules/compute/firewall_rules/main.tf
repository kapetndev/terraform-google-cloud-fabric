locals {
  _egress_rules = {
    for name, r in var.egress_rules :
    name => merge(r, { direction = "EGRESS" })
  }
  _ingress_rules = {
    for name, r in var.ingress_rules :
    name => merge(r, { direction = "INGRESS" })
  }
  firewall_rules = merge(local._egress_rules, local._ingress_rules)
}

resource "google_compute_firewall" "rules" {
  for_each    = local.firewall_rules
  description = each.value.description
  direction   = each.value.direction
  network     = var.network
  priority    = each.value.priority
  project     = var.project_id
  source_tags = each.value.direction == "EGRESS" ? null : each.value.source_tags
  target_tags = each.value.target_tags

  # For egress rules, if the destination ranges are not specified, use the
  # default of 0.0.0.0/0. Otherwsie use the specified destination ranges.
  destination_ranges = (
    each.value.direction == "EGRESS"
    ? (
      each.value.destination_ranges == null
      ? ["0.0.0.0/0"]
      : each.value.destination_ranges
    )
    : each.value.destination_ranges
  )

  # If the name is already prefixed with the network name, use it as-is. This
  # allows the consumer to specify firewall rules with names that are not
  # prefixed yet will be provision with a unique name.
  name = (startswith(each.key, var.network)
    ? each.key # name
    : "${var.network}-${each.key}"
  )

  # For ingress rules, if the source ranges are not specified, use the default
  # of 0.0.0.0/0. Otherwsie use the specified source ranges.
  source_ranges = (
    each.value.direction == "INGRESS"
    ? (
      each.value.source_ranges == null
      ? ["0.0.0.0/0"]
      : each.value.source_ranges
    )
    : each.value.source_ranges
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

  dynamic "log_config" {
    for_each = each.value.log_config_include_metadata != null ? [""] : []

    content {
      metadata = each.value.log_config_include_metadata ? "INCLUDE_ALL_METADATA" : "EXCLUDE_ALL_METADATA"
    }
  }
}

resource "google_compute_firewall" "allow_http" {
  count         = length(var.default_rules.http_ranges) != 0 ? 1 : 0
  description   = "Allow HTTP to instances matching tags"
  direction     = "INGRESS"
  name          = "${var.network}-allow-http"
  network       = var.network
  priority      = 1000
  project       = var.project_id
  source_ranges = var.default_rules.http_ranges
  target_tags   = var.default_rules.http_tags

  allow {
    ports    = ["80"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "allow_https" {
  count         = length(var.default_rules.https_ranges) != 0 ? 1 : 0
  description   = "Allow HTTPS to instances matching tags"
  direction     = "INGRESS"
  name          = "${var.network}-allow-https"
  network       = var.network
  priority      = 1000
  project       = var.project_id
  source_ranges = var.default_rules.https_ranges
  target_tags   = var.default_rules.https_tags

  allow {
    ports    = ["443"]
    protocol = "tcp"
  }
}

resource "google_compute_firewall" "allow_ssh" {
  count         = length(var.default_rules.ssh_ranges) != 0 ? 1 : 0
  description   = "Allow SSH to instances matching tags"
  direction     = "INGRESS"
  name          = "${var.network}-allow-ssh"
  network       = var.network
  priority      = 1000
  project       = var.project_id
  source_ranges = var.default_rules.ssh_ranges
  target_tags   = var.default_rules.ssh_tags

  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
}
