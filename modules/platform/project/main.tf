locals {
  name        = "${local.prefix}${var.name}"
  parent_id   = var.parent != null ? split("/", var.parent)[1] : null
  parent_type = var.parent != null ? split("/", var.parent)[0] : null
  prefix      = var.prefix != null ? "${var.prefix}-" : ""
  project_id  = var.project_id != null ? var.project_id : random_id.project_id[0].hex
}

resource "random_id" "project_id" {
  count       = var.project_id == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_project" "project" {
  auto_create_network = var.auto_create_network
  billing_account     = var.billing_account
  folder_id           = local.parent_type == "folders" ? local.parent_id : null
  name                = coalesce(var.descriptive_name, local.name)
  org_id              = local.parent_type == "organizations" ? local.parent_id : null
  project_id          = local.project_id
}

resource "google_project_service" "services" {
  for_each                   = var.services
  disable_dependent_services = var.disable_dependent_services
  disable_on_destroy         = var.disable_on_destroy
  project                    = google_project.project.project_id
  service                    = each.key
}

resource "google_tags_tag_binding" "binding" {
  for_each  = var.tag_bindings
  parent    = "//cloudresourcemanager.googleapis.com/projects/${google_project.project.number}"
  tag_value = each.value
}
