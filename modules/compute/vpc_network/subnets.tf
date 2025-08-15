locals {
  # Subnets may share a name accross regions, so we need to make sure the
  # resource identifiers are unique. In addition multiple subnets may be defined
  # within the same region. To ensure uniqueness we append the region to the
  # name.
  subnets = {
    for s in var.subnets : "${s.name}_${s.region}" => s
  }
}

resource "google_compute_subnetwork" "subnets" {
  for_each                 = local.subnets
  description              = each.value.description
  ip_cidr_range            = each.value.ip_cidr_range
  name                     = each.value.name
  network                  = google_compute_network.network.id
  private_ip_google_access = each.value.private_ip_google_access
  project                  = var.project_id
  purpose                  = each.value.purpose
  region                   = each.value.region
  role                     = each.value.role
  stack_type               = each.value.stack_type

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

  dynamic "secondary_ip_range" {
    for_each = { for r in each.value.secondary_ip_ranges : r.range_name => r }
    iterator = range

    content {
      ip_cidr_range = range.value.ip_cidr_range
      range_name    = range.value.range_name
    }
  }
}
