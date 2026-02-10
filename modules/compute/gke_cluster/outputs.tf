output "cluster_ca_certificate" {
  description = "Base64-encoded public certificate of the cluster's certificate authority. Used alongside the endpoint to authenticate a Kubernetes provider."
  value       = google_container_cluster.kubernetes_cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "endpoint" {
  description = "IP address of the cluster master API endpoint. Use this to configure a Kubernetes or Helm provider."
  value       = google_container_cluster.kubernetes_cluster.endpoint
  sensitive   = true
}

output "id" {
  description = "Fully qualified cluster ID in the format projects/PROJECT/locations/LOCATION/clusters/NAME. Use this as a stable reference when the cluster name alone is ambiguous."
  value       = google_container_cluster.kubernetes_cluster.id
}

output "name" {
  description = "The name of the cluster as known to the GKE API."
  value       = google_container_cluster.kubernetes_cluster.name
}

output "self_link" {
  description = "The URI of the cluster. Use this as a stable reference for IAM bindings or when referencing the cluster resource in other GCP configurations."
  value       = google_container_cluster.kubernetes_cluster.self_link
}

output "workload_identity_pool" {
  description = "The Workload Identity pool for this cluster, in the format PROJECT.svc.id.goog. Use this when constructing the IAM member string for Workload Identity bindings: serviceAccount:POOL[K8S_NAMESPACE/KSA_NAME]."
  value       = var.workload_identity_project_id != null ? "${var.workload_identity_project_id}.svc.id.goog" : null
}
