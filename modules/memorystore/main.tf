locals {
  name   = "${local.prefix}${var.name}"
  prefix = var.prefix != null ? "${var.prefix}-" : ""

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
  count       = var.descriptive_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_redis_instance" "default" {
  alternative_location_id = var.alternative_zone
  auth_enabled            = var.auth_enabled
  authorized_network      = var.authorized_network
  connect_mode            = var.connect_mode
  labels                  = var.labels
  location_id             = var.zone
  memory_size_gb          = var.memory_size_gb
  name                    = coalesce(var.descriptive_name, random_id.instance_name[0].hex)
  project                 = var.project_id
  redis_version           = var.redis_version
  region                  = var.region
  tier                    = var.tier

  dynamic "maintenance_policy" {
    for_each = var.maintenance_config != null ? [""] : []

    content {
      description = var.maintenance_config.description

      dynamic "weekly_maintenance_window" {
        for_each = var.maintenance_config.maintenance_window != null ? [""] : []

        content {
          day = local.days_of_week[var.maintenance_config.maintenance_window.day]

          start_time {
            hours = var.maintenance_policy.maintenance_window.hour
          }
        }
      }
    }
  }
}
