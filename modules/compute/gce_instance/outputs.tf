output "external_ip" {
  description = "The external IP address of the first network interface, if one is assigned. Null when external_access is false on the first interface."
  value       = try(google_compute_instance.instance.network_interface[0].access_config[0].nat_ip, null)
}

output "id" {
  description = "The server-assigned unique identifier of the instance."
  value       = google_compute_instance.instance.instance_id
}

output "internal_ip" {
  description = "The internal IP address of the first network interface. Use this for service configurations, DNS records, or firewall rules that reference the instance directly."
  value       = google_compute_instance.instance.network_interface[0].network_ip
}

output "name" {
  description = "The name of the instance as known to the GCP API. Use this when referencing the instance from other resources."
  value       = google_compute_instance.instance.name
}

output "self_link" {
  description = "The URI of the instance. Use this to reference the instance in other GCP resources such as instance groups, load balancer backends, and IAM bindings."
  value       = google_compute_instance.instance.self_link
}
