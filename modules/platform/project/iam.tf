locals {
  _group_iam_roles = distinct(flatten(values(var.group_iam)))
  _group_iam = {
    for role in local._group_iam_roles : role => [
      for email, roles in var.group_iam : "group:${email}" if contains(roles, role)
    ]
  }
  _iam_members = flatten([
    for role, members in var.iam_members : [
      for member in members : { role = role, member = member }
    ]
  ])
  iam = {
    for role in distinct(concat(keys(var.iam), keys(local._group_iam))) :
    role => concat(
      try(tolist(var.iam[role]), []),
      try(local._group_iam[role], [])
    )
  }
  iam_members = {
    for member_role in local._iam_members :
    "${member_role.role}-${member_role.member}" => {
      member = member_role.member
      role   = member_role.role
    }
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

resource "google_project_iam_member" "non_authoritative" {
  for_each = local.iam_members
  member   = each.value.member
  project  = google_project.project.project_id
  role     = each.value.role

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
