output "id" {
  description = "Fully qualified node pool ID in the format projects/PROJECT/locations/LOCATION/clusters/CLUSTER/nodePools/NAME."
  value       = google_container_node_pool.container_optimised_node_pool.id
}

output "name" {
  description = "The name of the node pool as known to the GKE API."
  value       = google_container_node_pool.container_optimised_node_pool.name
}
