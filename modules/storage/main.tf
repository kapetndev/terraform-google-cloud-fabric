locals {
  prefix = var.prefix != null ? "${var.prefix}-" : ""
}

resource "google_storage_bucket" "bucket" {
  labels                      = var.labels
  location                    = var.location
  name                        = "${local.prefix}${var.name}"
  project                     = var.project_id
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.uniform_bucket_level_access

  dynamic "autoclass" {
    for_each = var.autoclass ? [""] : []

    content {
      enabled = var.autoclass
    }
  }

  dynamic "cors" {
    for_each = var.cors != null ? [var.cors] : []

    content {
      max_age_seconds = each.value.max_age_seconds
      method          = each.value.method
      origin          = each.value.origin
      response_header = each.value.response_header
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    iterator = rule

    content {
      action {
        type          = rule.value.action_type
        storage_class = rule.value.action.storage_class
      }

      condition {
        age                        = rule.value.age
        created_before             = rule.value.created_before
        custom_time_before         = rule.value.custom_time_before
        days_since_custom_time     = rule.value.days_since_custom_time
        days_since_noncurrent_time = rule.value.days_since_noncurrent_time
        matches_prefix             = rule.value.matches_prefix
        matches_storage_class      = rule.value.matches_storage_class
        matches_suffix             = rule.value.matches_suffix
        noncurrent_time_before     = rule.value.noncurrent_time_before
        num_newer_versions         = rule.value.num_newer_versions
        with_state                 = rule.value.with_state
      }
    }
  }

  dynamic "logging" {
    for_each = var.logging_config != null ? [""] : []

    content {
      log_bucket        = var.logging_config.log_bucket
      log_object_prefix = var.logging_config.log_object_prefix
    }
  }

  dynamic "retention_policy" {
    for_each = var.retention_policy != null ? [""] : []

    content {
      retention_period = var.retention_policy.retention_period
      is_locked        = var.retention_policy.is_locked
    }
  }

  dynamic "versioning" {
    for_each = var.versioning ? [""] : []

    content {
      enabled = var.versioning
    }
  }

  dynamic "website" {
    for_each = var.website != null ? [""] : []

    content {
      main_page_suffix = var.website.main_page_suffix
      not_found_page   = var.website.not_found_page
    }
  }
}
