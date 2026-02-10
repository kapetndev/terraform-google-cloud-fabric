locals {
  # Subnets may share a name across regions, and multiple subnets may exist
  # within the same region. The resource key is region/name, which is
  # unambiguous because neither a region name nor a subnet name can contain a
  # forward slash. Putting region first means keys sort naturally by region in
  # plan output and terraform state list.
  subnets = {
    for s in var.subnets : "${s.region}/${s.name}" => s
  }
}

resource "google_compute_subnetwork" "subnets" {
  for_each                 = local.subnets
  description              = each.value.description
  ip_cidr_range            = each.value.ip_cidr_range
  ipv6_access_type         = each.value.ipv6_access_type
  name                     = each.value.name
  network                  = google_compute_network.network.id
  private_ip_google_access = each.value.private_ip_google_access
  project                  = var.project_id
  purpose                  = each.value.purpose
  region                   = each.value.region
  role                     = each.value.role
  stack_type               = each.value.stack_type

  # Flow log export configuration. The block must be entirely absent when
  # logging is disabled, so a dynamic block is required. When present, the
  # iterator is the log_config object itself rather than the [""] sentinel,
  # which keeps content references clean.
  dynamic "log_config" {
    for_each = each.value.log_config != null ? [each.value.log_config] : []
    iterator = config

    content {
      aggregation_interval = config.value.aggregation_interval
      filter_expr          = config.value.filter_expr
      flow_sampling        = config.value.flow_sampling
      metadata             = config.value.metadata
      metadata_fields      = config.value.metadata_fields
    }
  }

  # Secondary IP range configuration. The block must be entirely absent when no
  # secondary ranges are configured, so a dynamic block is required. When
  # present, the iterator is the secondary range object itself rather than the
  # [""] sentinel, which keeps content references clean.
  dynamic "secondary_ip_range" {
    for_each = { for r in each.value.secondary_ip_ranges : r.range_name => r }
    iterator = range

    content {
      ip_cidr_range = range.value.ip_cidr_range
      range_name    = range.value.range_name
    }
  }
}
