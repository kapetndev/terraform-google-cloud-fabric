output "instance_id" {
  description = "The server-assigned unique identifier of the instance."
  value       = google_compute_instance.instance.instance_id
}
