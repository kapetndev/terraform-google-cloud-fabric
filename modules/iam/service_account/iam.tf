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
      try(local._group_iam[role], []),
    )
  }
}

resource "google_service_account_iam_binding" "authoritative" {
  for_each           = local.iam
  members            = each.value
  role               = each.key
  service_account_id = google_service_account.service_account.name
}

resource "google_service_account_iam_binding" "bindings" {
  for_each           = var.iam_bindings
  members            = each.value.members
  role               = each.key
  service_account_id = google_service_account.service_account.name

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}

resource "google_service_account_iam_member" "bindings" {
  for_each           = var.iam_members
  member             = each.value.member
  role               = each.value.role
  service_account_id = google_service_account.service_account.name

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}
