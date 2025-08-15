output "service_account_email" {
  description = "The email address of the service account."
  value       = google_service_account.service_account.email
}
