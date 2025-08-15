locals {
  key_ring = (
    var.create_key_ring ?
    google_kms_key_ring.key_ring[0] :
    data.google_kms_key_ring.key_ring[0]
  )
}

data "google_kms_key_ring" "key_ring" {
  count    = var.create_key_ring ? 0 : 1
  location = var.location
  name     = var.key_ring_name
  project  = var.project_id
}

resource "google_kms_key_ring" "key_ring" {
  count    = var.create_key_ring ? 1 : 0
  location = var.location
  name     = var.key_ring_name
  project  = var.project_id

  # KeyRings cannot be deleted from Google Cloud Platform. Destroying a
  # Terraform-managed KeyRing will remove it from state but will not delete the
  # resource from the project.
  lifecycle {
    prevent_destroy = true
  }
}

resource "google_kms_crypto_key" "keys" {
  for_each                      = var.keys
  destroy_scheduled_duration    = each.value.destroy_scheduled_duration
  key_ring                      = local.key_ring
  labels                        = each.value.labels
  name                          = each.key
  purpose                       = each.value.purpose
  rotation_period               = each.value.rotation_period
  skip_initial_version_creation = each.value.skip_initial_version_creation

  dynamic "version_template" {
    for_each = each.value.version_template != null ? [each.value.version_template] : []
    iterator = template

    content {
      algorithm        = template.value.algorithm
      protection_level = template.value.protection_level
    }
  }

  # CryptoKeys cannot be deleted from Google Cloud Platform. Destroying a
  # Terraform-managed CryptoKey will remove it from state and delete all
  # CryptoKeyVersions, rendering the key unusable, but will not delete the
  # resource from the project. When Terraform destroys these keys, any data
  # previously encrypted with these keys will be irrecoverable. For this
  # reason, it is strongly recommended that you add lifecycle hooks to the
  # resource to prevent accidental destruction.
  lifecycle {
    prevent_destroy = true
  }
}
