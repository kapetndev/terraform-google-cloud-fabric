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

resource "google_organization_iam_binding" "authoritative" {
  for_each = local.iam
  members  = each.value
  org_id   = var.organization_id
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

resource "google_organization_iam_binding" "bindings" {
  for_each = var.iam_bindings
  members  = each.value
  org_id   = var.organization_id
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

resource "google_organization_iam_member" "bindings" {
  for_each = var.iam_members
  member   = each.value.member
  org_id   = var.organization_id
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
