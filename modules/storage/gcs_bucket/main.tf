locals {
  name   = "${local.prefix}${var.name}"
  prefix = var.prefix != null ? "${var.prefix}-" : ""
}

resource "google_storage_bucket" "bucket" {
  force_destroy               = var.force_destroy
  labels                      = var.labels
  location                    = var.location
  name                        = local.name
  project                     = var.project_id
  public_access_prevention    = var.public_access_prevention
  requester_pays              = var.requester_pays
  storage_class               = var.storage_class
  uniform_bucket_level_access = var.hierarchical_namespace || var.uniform_bucket_level_access

  # Retention and holds.
  # https://cloud.google.com/storage/docs/object-holds
  # https://cloud.google.com/storage/docs/object-lock
  default_event_based_hold = var.default_event_based_hold
  enable_object_retention  = var.enable_object_retention

  dynamic "autoclass" {
    for_each = var.autoclass != null ? [var.autoclass] : []
    iterator = autoclass

    content {
      enabled                = true
      terminal_storage_class = autoclass.value.terminal_storage_class
    }
  }

  dynamic "cors" {
    for_each = var.cors != null ? [""] : []

    content {
      max_age_seconds = var.cors.max_age_seconds
      method          = var.cors.methods
      origin          = var.cors.origins
      response_header = var.cors.response_header_values
    }
  }

  dynamic "hierarchical_namespace" {
    for_each = var.hierarchical_namespace ? [""] : []

    content {
      enabled = var.hierarchical_namespace
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
        age                                     = rule.value.condition.age
        created_before                          = rule.value.condition.created_before
        custom_time_before                      = rule.value.condition.custom_time_before
        days_since_custom_time                  = rule.value.condition.days_since_custom_time
        days_since_noncurrent_time              = rule.value.condition.days_since_noncurrent_time
        matches_prefix                          = rule.value.condition.matches_prefix
        matches_storage_class                   = rule.value.condition.matches_storage_class
        matches_suffix                          = rule.value.condition.matches_suffix
        noncurrent_time_before                  = rule.value.condition.noncurrent_time_before
        num_newer_versions                      = rule.value.condition.num_newer_versions
        send_age_if_zero                        = rule.value.condition.send_age_if_zero
        send_days_since_custom_time_if_zero     = rule.value.condition.send_days_since_custom_time_if_zero
        send_days_since_noncurrent_time_if_zero = rule.value.condition.send_days_since_noncurrent_time_if_zero
        send_num_newer_versions_if_zero         = rule.value.condition.send_num_newer_versions_if_zero
        with_state                              = rule.value.condition.with_state
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

  versioning {
    enabled = var.versioning
  }

  dynamic "website" {
    for_each = var.website != null ? [""] : []

    content {
      main_page_suffix = var.website.main_page_suffix
      not_found_page   = var.website.not_found_page
    }
  }

  lifecycle {
    precondition {
      condition     = !(var.hierarchical_namespace && var.default_event_based_hold)
      error_message = "hierarchical_namespace: cannot be enabled at the same time as `default_event_based_hold`."
    }
  }
}
