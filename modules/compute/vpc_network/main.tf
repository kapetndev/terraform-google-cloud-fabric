resource "google_compute_network" "network" {
  auto_create_subnetworks                   = var.auto_create_subnetworks
  delete_default_routes_on_create           = var.delete_default_routes_on_create
  description                               = var.description
  mtu                                       = var.mtu
  name                                      = var.name
  network_firewall_policy_enforcement_order = var.network_firewall_policy_enforcement_order
  project                                   = var.project_id
  routing_mode                              = var.routing_mode
}
