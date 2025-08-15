output "id" {
  description = "The network ID."
  value       = google_compute_network.network.id
}

output "subnets" {
  description = "The subnets in the network."
  value = {
    for name, s in google_compute_subnetwork.subnets :
    name => {
      id                   = s.id
      gateway_address      = s.gateway_address
      ip_cidr_range        = s.ip_cidr_range
      ipv6_cidr_range      = s.ipv6_cidr_range
      external_ipv6_prefix = s.external_ipv6_prefix
    }
  }
}
