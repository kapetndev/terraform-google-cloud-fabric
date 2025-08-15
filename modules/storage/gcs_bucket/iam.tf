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

resource "google_storage_bucket_iam_binding" "authoritative" {
  for_each = local.iam
  bucket   = google_storage_bucket.bucket.name
  members  = each.value
  role     = each.key
}

resource "google_storage_bucket_iam_binding" "bindings" {
  for_each = var.iam_bindings
  bucket   = google_storage_bucket.bucket.name
  members  = each.value
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

resource "google_storage_bucket_iam_member" "non_authoritative" {
  for_each = var.iam_members
  bucket   = google_storage_bucket.bucket.name
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
