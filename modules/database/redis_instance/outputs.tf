output "instance_name" {
  description = "The name of the Redis instance."
  value       = google_redis_instance.default.name
}

output "connection_name" {
  description = "Hostname or IP address and port of the exposed Redis endpoint used by clients to connect to the service."
  value       = "${google_redis_instance.default.host}:${google_redis_instance.default.port}"
}
