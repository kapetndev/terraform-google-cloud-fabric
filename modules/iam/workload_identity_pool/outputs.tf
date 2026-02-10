output "pool_id" {
  description = "The ID of the Workload Identity Pool. Use this when constructing the Workload Identity member string: `principalSet://iam.googleapis.com/{projects/PROJECT_ID/locations/global/workloadIdentityPools/POOL_ID}/attribute.ATTRIBUTE/VALUE`."
  value       = google_iam_workload_identity_pool.pool.id
}

output "pool_name" {
  description = "The ID of the Workload Identity Pool. Use this when constructing the Workload Identity member string: `principalSet://iam.googleapis.com/{projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID}/attribute.ATTRIBUTE/VALUE`."
  value       = google_iam_workload_identity_pool.pool.name
}

output "identity_providers" {
  description = "Map of identity provider IDs keyed by provider name, matching the keys supplied in `var.identity_providers`. Use these IDs when constructing the full provider resource name for use in attribute conditions or external identity configurations."
  value = {
    for k, v in google_iam_workload_identity_pool_provider.identity_providers :
    k => {
      "provider_id"   = v.id
      "provider_name" = v.name
    }
  }
}
