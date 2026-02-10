output "email" {
  description = "The email address of the service account. Use this when granting IAM roles to the service account, or when configuring Workload Identity bindings."
  value       = google_service_account.service_account.email
}

output "id" {
  description = "The fully qualified resource ID of the service account in the format `projects/PROJECT/serviceAccounts/EMAIL`. Use this when referencing the service account as a resource to bind IAM roles to."
  value       = google_service_account.service_account.id
}

output "member" {
  description = "The IAM member string for the service account in the format `serviceAccount:EMAIL`. Ready for use directly in IAM binding member lists."
  value       = google_service_account.service_account.member
}

# TODO: check this. I'm not sure about this one.
output "name" {
  description = "The fully qualified name of the service account in the format `projects/PROJECT/serviceAccounts/EMAIL`. Use this when referencing the service account from other service account IAM bindings."
  value       = google_service_account.service_account.name
}
