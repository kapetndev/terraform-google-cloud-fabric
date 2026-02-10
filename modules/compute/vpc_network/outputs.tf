output "id" {
  description = "The unique identifier of the network."
  value       = google_compute_network.network.id
}

output "name" {
  description = "The name of the network. Use this when referencing the network from other modules, such as the gke_cluster or vpc_firewall modules which take a network name as input."
  value       = google_compute_network.network.name
}

output "self_link" {
  description = "The URI of the network. Use this when a resource requires a fully qualified network reference rather than a short name."
  value       = google_compute_network.network.self_link
}

output "subnets" {
  description = "Map of created subnets keyed by region/name, exposing the attributes most commonly needed by downstream resources."
  value = {
    for name, s in google_compute_subnetwork.subnets :
    name => {
      id                   = s.id
      self_link            = s.self_link
      gateway_address      = s.gateway_address
      ip_cidr_range        = s.ip_cidr_range
      ipv6_cidr_range      = s.ipv6_cidr_range
      external_ipv6_prefix = s.external_ipv6_prefix
    }
  }
}
