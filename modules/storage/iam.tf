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
      role   = member_role.role,
      member = member_role.member
    }
  }
}

resource "google_storage_bucket_iam_binding" "authoritative" {
  for_each = local.iam
  bucket   = google_storage_bucket.bucket.name
  members  = each.value
  role     = each.key

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []

    content {
      description = each.value.description
      expression  = each.value.expression
      title       = each.value.title
    }
  }
}

resource "google_storage_bucket_iam_member" "non_authoritative" {
  for_each = local.iam_members
  bucket   = google_storage_bucket.bucket.name
  member   = each.value.member
  role     = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []

    content {
      description = each.value.description
      expression  = each.value.expression
      title       = each.value.title
    }
  }
}
