locals {
  # Derive the set of unique regions that have at least one NAT-enabled subnet.
  # The router is regional, so one router per region is required.
  nat_regions = toset([
    for key, s in local.subnets : s.region if s.nat != null
  ])

  # Flatten all NAT-enabled subnets into a list of objects that include their
  # region, for use in the NAT gateway subnetwork blocks. Keyed by region/name
  # to match the existing subnet key convention.
  nat_subnets = {
    for key, s in local.subnets : key => s if s.nat != null
  }

  # Group by region+mode so that AUTO_ONLY and MANUAL_ONLY subnets in the same
  # region get separate NAT gateways on the same router.
  nat_gateways = {
    for pair in distinct([
      for key, s in local.nat_subnets : {
        region = s.region
        mode   = length(s.nat.ip_self_links) > 0 ? "manual" : "auto"
      }
    ]) : "${pair.region}/${pair.mode}" => pair
  }

  nat_subnets_by_gateway = {
    for gw_key, gw in local.nat_gateways :
    gw_key => {
      for key, s in local.nat_subnets : key => s
      if s.region == gw.region &&
      (gw.mode == "manual") == (length(s.nat.ip_self_links) > 0)
    }
  }
}

resource "google_compute_router" "nat_routers" {
  for_each    = local.nat_regions
  name        = "${var.name}-${each.key}-router"
  description = "Cloud Router for NAT egress in ${each.key}."
  network     = google_compute_network.network.id
  project     = var.project_id
  region      = each.key
}

resource "google_compute_router_nat" "nat_gateways" {
  for_each = local.nat_gateways
  name     = "${var.name}-${each.value.region}-${each.value.mode}-nat"
  project  = var.project_id
  region   = each.value.region
  router   = google_compute_router.nat_routers[each.value.region].name

  # Use static IPs if any subnet in this region has reserved them, otherwise
  # fall back to AUTO_ONLY.
  nat_ip_allocate_option = each.value.mode == "manual" ? "MANUAL_ONLY" : "AUTO_ONLY"

  nat_ips = each.value.mode == "manual" ? flatten([
    for key, s in local.nat_subnets_by_gateway[each.key] :
    s.nat.ip_self_links
  ]) : []

  # The source IP range option is determined by the gateway-level configuration,
  # which is shared across all subnets attached to the gateway. It is preferable
  # to be exlicit about which subnets are included in the NAT configuration
  # because the default ALL_SUBNETWORKS_ALL_IP_RANGES option may have unintended
  # consequences if new subnets are added to the network in the future.
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  dynamic "subnetwork" {
    for_each = local.nat_subnets_by_gateway[each.key]
    iterator = subnet

    content {
      name = google_compute_subnetwork.subnets[subnet.key].self_link

      # The source IP range option is determined by the subnet-level
      # configuration.
      source_ip_ranges_to_nat = subnet.value.nat.source_ip_ranges_to_nat

      # When the source IP range option contains LIST_OF_SECONDARY_IP_RANGES,
      # the secondary range names must be specified. The block must be entirely
      # absent when the option is not set to LIST_OF_SECONDARY_IP_RANGES.
      secondary_ip_range_names = contains(subnet.value.nat.source_ip_ranges_to_nat, "LIST_OF_SECONDARY_IP_RANGES") ? subnet.value.nat.secondary_ip_range_names : []
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
