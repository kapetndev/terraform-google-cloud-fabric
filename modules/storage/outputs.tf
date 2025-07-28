output "id" {
  description = "ID of the bucket."
  value       = resource.google_storage_bucket.bucket.name
}

output "url" {
  description = "Bucket URL."
  value       = "gs://${resource.google_storage_bucket.bucket.name}"
}
