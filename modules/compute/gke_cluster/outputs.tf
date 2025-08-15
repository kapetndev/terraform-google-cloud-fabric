output "name" {
  description = "Kubernetes cluster name."
  value       = google_container_cluster.kubernetes_cluster.name
}

output "cluster_ca_certificate" {
  description = "Base64 encoded public certificate that is the root of trust for the cluster."
  value       = google_container_cluster.kubernetes_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}
