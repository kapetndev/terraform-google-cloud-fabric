output "id" {
  description = "The fully qualified resource ID of the instance."
  value       = google_redis_instance.default.id
}

output "name" {
  description = "The name of the instance as known to the GCP API."
  value       = google_redis_instance.default.name
}

output "host" {
  description = "The private IP address of the instance. Use this to configure application connection strings."
  value       = google_redis_instance.default.host
}

output "port" {
  description = "The port number the instance is listening on."
  value       = google_redis_instance.default.port
}

output "endpoint" {
  description = "The host:port endpoint of the instance. Convenience output combining `host` and `port` for use in connection strings."
  value       = "${google_redis_instance.default.host}:${google_redis_instance.default.port}"
}
