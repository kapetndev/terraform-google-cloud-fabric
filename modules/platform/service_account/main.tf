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
      try(local._group_iam[role], []),
    )
  }
  iam_members = {
    for member_role in local._iam_members :
    "${member_role.role}-${member_role.member}" => {
      role   = member_role.role
      member = member_role.member
    }
  }
  prefix = var.prefix != null ? "${var.prefix}-" : ""
}

resource "google_service_account" "service_account" {
  account_id   = "${local.prefix}${var.name}"
  description  = var.description
  display_name = coalesce(var.display_name, var.name)
  project      = var.project_id
}

resource "google_service_account_iam_binding" "authoritative" {
  for_each           = local.iam
  members            = each.value
  role               = each.key
  service_account_id = google_service_account.service_account.name

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []

    content {
      description = condition.description
      expression  = condition.expression
      title       = condition.title
    }
  }
}

resource "google_service_account_iam_member" "non_authoritative" {
  for_each           = local.iam_members
  member             = each.value.member
  role               = each.value.role
  service_account_id = google_service_account.service_account.name

  dynamic "condition" {
    for_each = each.value.condition != null ? [each.value.condition] : []

    content {
      description = condition.description
      expression  = condition.expression
      title       = condition.title
    }
  }
}
