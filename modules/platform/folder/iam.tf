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

# google_folder_iam_binding is authoritative per role — it overwrites all
# members for that role on every apply. If the same role appears in both the
# `iam`/`group_iam` variables (rendered here) and the `iam_bindings` variable
# (rendered below), the two resources will conflict on every apply, each
# removing the members set by the other.  Ensure each role appears in only one
# of these variables.
resource "google_folder_iam_binding" "authoritative" {
  for_each = local.iam
  folder   = google_folder.folder.name
  members  = each.value
  role     = each.key
}

resource "google_folder_iam_binding" "bindings" {
  for_each = var.iam_bindings
  folder   = google_folder.folder.name
  members  = each.value.members
  role     = each.key

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}

resource "google_folder_iam_member" "bindings" {
  for_each = var.iam_members
  folder   = google_folder.folder.name
  member   = each.value.member
  role     = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}
