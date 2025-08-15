resource "google_iam_workload_identity_pool" "pool" {
  description               = var.description
  disabled                  = var.disabled
  display_name              = coalesce(var.display_name, var.name)
  project                   = var.project_id
  workload_identity_pool_id = var.name
}

resource "google_iam_workload_identity_pool_provider" "identity_providers" {
  for_each                           = var.identity_providers
  attribute_condition                = each.value.attribute_condition
  attribute_mapping                  = each.value.attribute_mapping
  description                        = each.value.description
  disabled                           = each.value.disabled
  display_name                       = coalesce(each.value.display_name, each.key)
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.pool.workload_identity_pool_id
  workload_identity_pool_provider_id = each.key

  dynamic "aws" {
    for_each = each.value.aws != null ? [each.value.aws] : []
    iterator = aws

    content {
      account_id = aws.value.account_id
    }
  }

  dynamic "oidc" {
    for_each = each.value.oidc != null ? [each.value.oidc] : []
    iterator = oidc

    content {
      allowed_audiences = oidc.value.allowed_audiences
      issuer_uri        = oidc.value.issuer_uri
    }
  }
}
