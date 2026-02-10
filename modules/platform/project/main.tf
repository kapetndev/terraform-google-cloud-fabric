locals {
  # When not using a verbatim name, we generate a random ID to use as the suffix
  # for the project name. This is to ensure that the name is unique and does not
  # conflict with any other project in the organisation. An optional prefix can
  # be added to the name, which is useful for grouping instances.
  name   = "${local.prefix}${var.name}"
  prefix = var.prefix != null ? "${var.prefix}-" : ""

  parent_id   = var.parent != null ? split("/", var.parent)[1] : null
  parent_type = var.parent != null ? split("/", var.parent)[0] : null
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

  lifecycle {
    precondition {
      condition     = !(var.descriptive_name != null && var.name != "")
      error_message = "name: `name` and `descriptive_name` are mutually exclusive. Set one or the other, not both."
    }
  }
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
