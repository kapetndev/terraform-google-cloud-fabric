locals {
  _group_iam_roles = distinct(flatten(values(var.group_iam)))
  _group_iam = {
    for role in local._group_iam_roles : role => [
      for email, roles in var.group_iam : "group:${email}" if contains(roles, role)
    ]
  }
  iam = {
    for role in distinct(concat(keys(var.iam), keys(local._group_iam))) :
    role => concat(
      try(tolist(var.iam[role]), []),
      try(local._group_iam[role], [])
    )
  }
}

# google_project_iam_binding is authoritative per role — it overwrites all
# members for that role on every apply. If the same role appears in both the
# `iam`/`group_iam` variables (rendered here) and the `iam_bindings` variable
# (rendered below), the two resources will conflict on every apply, each
# removing the members set by the other.  Ensure each role appears in only one
# of these variables.
resource "google_project_iam_binding" "authoritative" {
  for_each = local.iam
  members  = each.value
  project  = google_project.project.project_id
  role     = each.key

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_binding" "bindings" {
  for_each = var.iam_bindings
  members  = each.value.members
  project  = google_project.project.project_id
  role     = each.key

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }

  depends_on = [
    google_project_service.services,
  ]
}

resource "google_project_iam_member" "bindings" {
  for_each = var.iam_members
  member   = each.value.member
  project  = google_project.project.project_id
  role     = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }

  depends_on = [
    google_project_service.services,
  ]
}
