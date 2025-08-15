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
  key_iam = {
    for binding in flatten([
      for key, config in var.keys : [
        for role, members in try(config.iam, {}) : {
          key     = key
          members = members
          role    = role
        }
      ]
    ]) : "${binding.key}-${binding.role}" => binding
  }
  key_iam_bindings = {
    for binding in flatten([
      for key, config in var.keys : [
        for name, binding in try(config.iam_bindings, {}) : {
          key       = key
          name      = name
          members   = binding.members
          role      = binding.role
          condition = binding.condition
        }
      ]
    ]) : "${binding.key}-${binding.name}" => binding
  }
  key_iam_members = {
    for binding in flatten([
      for key, config in var.keys : [
        for name, binding in try(config.iam_members, {}) : {
          key       = key
          name      = name
          member    = binding.member
          role      = binding.role
          condition = binding.condition
        }
      ]
    ]) : "${binding.key}-${binding.name}" => binding
  }
}

resource "google_kms_key_ring_iam_binding" "authoritative" {
  for_each    = local.iam
  key_ring_id = local.key_ring.id
  members     = each.value
  role        = each.key
}

resource "google_kms_key_ring_iam_binding" "bindings" {
  for_each    = var.iam_bindings
  key_ring_id = local.key_ring.id
  members     = each.value.members
  role        = each.key

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}

resource "google_kms_key_ring_iam_member" "bindings" {
  for_each    = var.iam_members
  key_ring_id = local.key_ring.id
  member      = each.value.member
  role        = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}

resource "google_kms_crypto_key_iam_binding" "authoritative" {
  for_each      = local.key_iam
  crypto_key_id = google_kms_crypto_key.keys[each.value.key].id
  members       = each.value.members
  role          = each.value.role
}

resource "google_kms_crypto_key_iam_binding" "bindings" {
  for_each      = local.key_iam_bindings
  crypto_key_id = google_kms_crypto_key.keys[each.value.key].id
  members       = each.value.members
  role          = each.key

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}

resource "google_kms_crypto_key_iam_member" "bindings" {
  for_each      = local.key_iam_members
  crypto_key_id = google_kms_crypto_key.keys[each.value.key].id
  member        = each.value.member
  role          = each.value.role

  dynamic "condition" {
    for_each = each.value.condition != null ? [""] : []

    content {
      description = each.value.condition.description
      expression  = each.value.condition.expression
      title       = each.value.condition.title
    }
  }
}
