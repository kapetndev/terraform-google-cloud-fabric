output "key_ring_id" {
  description = "The fully qualified resource ID of the KMS key ring in the format `projects/PROJECT/locations/LOCATION/keyRings/NAME`. Use this when granting IAM roles on the key ring or referencing the key ring from other resources."
  value       = local.key_ring.id
}

output "key_ring_name" {
  description = "The short name of the KMS key ring."
  value       = local.key_ring.name
}

output "key_ids" {
  description = "Map of crypto key IDs keyed by the name supplied in `var.keys`. Each value is the fully qualified resource ID in the format `projects/PROJECT/locations/LOCATION/keyRings/RING/cryptoKeys/NAME`. Use these when granting Cloud KMS encrypter/decrypter roles to GCP service agents, e.g. for CMEK on Cloud SQL, GCS, or Compute."
  value = {
    for k, v in google_kms_crypto_key.keys : k => v.id
  }
}
