output "workload_identity_pool_id" {
  description = "The ID of the pool."
  value       = google_iam_workload_identity_pool.pool.workload_identity_pool_id
}

output "identity_provider_ids" {
  description = "The IDs of the identity providers."
  value       = values(google_iam_workload_identity_pool_provider.identity_providers)[*].workload_identity_pool_provider_id
}
