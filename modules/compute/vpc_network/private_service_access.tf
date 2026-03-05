# Private Services Access allocates IP ranges in your VPC and peers them with
# Google's service producer network via servicenetworking.googleapis.com. This
# enables private connectivity to managed services such as Cloud SQL,
# Memorystore, and AlloyDB without traffic leaving the internal network.
#
# This is distinct from Private Service Connect, which uses forwarding rules
# and service attachments to reach Google APIs by private IP address.

resource "google_compute_global_address" "private_services_access_ranges" {
  for_each      = var.private_services_access_ranges
  address       = split("/", each.value)[0]
  address_type  = "INTERNAL"
  description   = "Reserved range for Private Service Access"
  name          = each.key
  network       = google_compute_network.network.id
  prefix_length = try(tonumber(split("/", each.value)[1]), 16)
  project       = var.project_id
  purpose       = "VPC_PEERING"
}

resource "google_service_networking_connection" "private_services_access" {
  count   = length(var.private_services_access_ranges) != 0 ? 1 : 0
  network = google_compute_network.network.id
  service = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [
    for _, addr in google_compute_global_address.private_services_access_ranges :
    addr.name
  ]
}
