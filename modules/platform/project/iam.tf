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

resource "google_project_iam_binding" "authoritative" {
  for_each = local.iam
  members  = each.value
  project  = google_project.project.project_id
  role     = each.key

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []

    content {
      description = each.value.description
      expression  = each.value.expression
      title       = each.value.title
    }
  }

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
