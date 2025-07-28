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
    for_each = each.value.log_config != null ? [""] : []

    content {
      aggregation_interval = each.value.log_config.aggregation_interval
      filter_expr          = each.value.log_config.filter_expr
      flow_sampling        = each.value.log_config.flow_sampling
      metadata             = each.value.log_config.metadata
      metadata_fields      = each.value.log_config.metadata_fields
    }
  }

  dynamic "secondary_ip_range" {
    for_each = {
      for r in each.value.secondary_ip_ranges : r.range_name => r
    }

    content {
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
      range_name    = secondary_ip_range.value.range_name
    }
  }
}
