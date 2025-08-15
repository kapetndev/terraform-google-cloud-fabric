locals {
  prefix = var.prefix != null ? "${var.prefix}-" : ""
}

resource "google_service_account" "service_account" {
  account_id   = "${local.prefix}${var.name}"
  description  = var.description
  display_name = coalesce(var.display_name, var.name)
  project      = var.project_id
}
