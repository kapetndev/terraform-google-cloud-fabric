locals {
  policies = {
    for policy, spec in var.policies :
    policy => merge(spec, {
      is_boolean_policy = alltrue([for rule in spec.rules : rule.allow == null && rule.deny == null && rule.enforce != null])
      rules = [
        for rule in spec.rules :
        merge(rule, {
          has_values = (
            length(coalesce(try(rule.allow.values, []), [])) > 0 ||
            length(coalesce(try(rule.deny.values, []), [])) > 0
          )
        })
      ]
    })
  }
}

resource "google_org_policy_policy" "policies" {
  for_each = local.policies
  name     = "${google_project.project.project_id}/policies/${each.value}"
  parent   = google_project.project.project_id

  dynamic "spec" {
    for_each = lookup(each.value, "dry_run", false) ? [] : [each.value]
    iterator = spec

    content {
      inherit_from_parent = spec.value.inherit_from_parent
      reset               = spec.value.reset

      dynamic "rules" {
        for_each = spec.value.rules
        iterator = rule

        content {
          allow_all  = try(rule.value.allow.all, false) == true ? "TRUE" : null
          deny_all   = try(rule.value.deny.all, false) == true ? "TRUE" : null
          enforce    = (spec.value.is_boolean_policy && rule.value.enforce == true) ? "TRUE" : null
          parameters = rule.value.parameters

          dynamic "condition" {
            for_each = rule.value.condition != null ? [rule.value.condition] : []
            iterator = condition

            content {
              description = condition.value.description
              expression  = condition.value.expression
              location    = condition.value.location
              title       = condition.value.title
            }
          }

          dynamic "values" {
            for_each = rule.value.has_values ? [""] : []

            content {
              allowed_values = try(rule.value.allow.values, null)
              denied_values  = try(rule.value.deny.values, null)
            }
          }
        }
      }
    }
  }

  dynamic "dry_run_spec" {
    for_each = lookup(each.value, "dry_run", false) ? [each.value] : []
    iterator = spec

    content {
      inherit_from_parent = spec.value.inherit_from_parent
      reset               = spec.value.reset

      dynamic "rules" {
        for_each = spec.value.rules
        iterator = rule

        content {
          allow_all  = try(rule.value.allow.all, false) == true ? "TRUE" : null
          deny_all   = try(rule.value.deny.all, false) == true ? "TRUE" : null
          enforce    = (spec.value.is_boolean_policy && rule.value.enforce == true) ? "TRUE" : null
          parameters = rule.value.parameters

          dynamic "condition" {
            for_each = rule.value.condition != null ? [rule.value.condition] : []
            iterator = condition

            content {
              description = condition.value.description
              expression  = condition.value.expression
              location    = condition.value.location
              title       = condition.value.title
            }
          }

          dynamic "values" {
            for_each = rule.value.has_values ? [""] : []

            content {
              allowed_values = try(rule.value.allow.values, null)
              denied_values  = try(rule.value.deny.values, null)
            }
          }
        }
      }
    }
  }
}
