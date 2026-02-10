locals {
  # When not using a verbatim name, we generate a random ID to use as the suffix
  # for the instance name. This is to ensure that the name is unique and does
  # not conflict with any other instance in the project. An optional prefix can
  # be added to the name, which is useful for grouping instances.
  name   = var.name != null ? "${local.prefix}${var.name}" : null
  prefix = var.prefix != null ? "${var.prefix}-" : ""

  # The instance name is either the caller-specified override or a generated
  # random name.
  instance_name = var.override_name != null ? var.override_name : random_id.instance_name[0].hex

  days_of_week = {
    1 = "MONDAY"
    2 = "TUESDAY"
    3 = "WEDNESDAY"
    4 = "THURSDAY"
    5 = "FRIDAY"
    6 = "SATURDAY"
    7 = "SUNDAY"
  }
}

resource "random_id" "instance_name" {
  count       = var.override_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_redis_instance" "instance" {
  alternative_location_id = var.alternative_zone
  auth_enabled            = var.auth_enabled
  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  labels                  = var.labels
  location_id             = var.zone
  memory_size_gb          = var.memory_size_gb
  name                    = local.instance_name
  project                 = var.project_id
  redis_version           = var.redis_version
  region                  = var.region
  reserved_ip_range       = var.reserved_ip_range
  tier                    = var.tier

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy.maintenance_window != null ? [""] : []

    content {
      description = var.maintenance_policy.description

      weekly_maintenance_window {
        day = local.days_of_week[var.maintenance_policy.maintenance_window.day]

        start_time {
          hours = var.maintenance_policy.maintenance_window.hour
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = (var.override_name == null) != (var.name == null)
      error_message = "name: exactly one of `name` or `override_name` must be set."
    }
  }
}
