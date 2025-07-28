locals {
  min_master_version = (
    var.kubernetes_version_release_channel != null
    ? data.google_container_engine_versions.supported[0].release_channel_default_version[var.kubernetes_version_release_channel]
    : var.kubernetes_version
  )
  name   = "${local.prefix}${var.name}"
  prefix = var.prefix != null ? "${var.prefix}-" : ""
}

data "google_container_engine_versions" "supported" {
  count          = var.kubernetes_version_release_channel != null ? 1 : 0
  location       = var.location
  project        = var.project_id
  version_prefix = var.kubernetes_version
}

resource "random_id" "cluster_name" {
  count       = var.descriptive_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_container_cluster" "kubernetes_cluster" {
  description     = var.description
  location        = var.location
  name            = coalesce(var.descriptive_name, random_id.cluster_name[0].hex)
  network         = var.network
  project         = var.project_id
  resource_labels = var.labels
  subnetwork      = var.subnetwork

  # Enable intranode visibility to expose pod-to-pod traffic to the VPC for flow
  # logging.
  enable_intranode_visibility = var.enable_intranode_visibility

  # It is not possible to create a cluster with no node pool defined, but it is
  # desirable to use a node pool that is managed separately. Therefore it is
  # necessary to create the smallest possible default node pool and immediately
  # delete it.
  #
  # This is deliberately not configurable as it is not recommended to use the
  # default node pool.
  initial_node_count       = 1
  remove_default_node_pool = true

  # Send all logging and monitoring data to Google Cloud Monitoring.
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Ensure the minimum version of the master. GKE will auto-update the master to
  # new versions, so this does not guarantee the current master version.
  min_master_version = local.min_master_version

  # Configure the cluster addons. The addons listed are all enabled by default
  # when the cluster is created.
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }
  }

  # Allows for Google Groups to work with Kubernetes role-based access control
  # (RBAC).
  dynamic "authenticator_groups_config" {
    for_each = var.security_group != null ? [""] : []

    content {
      security_group = var.security_group
    }
  }

  # https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips
  dynamic "ip_allocation_policy" {
    for_each = var.ip_allocation_policy != null ? [""] : []

    content {
      cluster_ipv4_cidr_block       = var.ip_allocation_policy.cluster_ipv4_cidr_block
      cluster_secondary_range_name  = var.ip_allocation_policy.cluster_secondary_range_name
      services_ipv4_cidr_block      = var.ip_allocation_policy.services_ipv4_cidr_block
      services_secondary_range_name = var.ip_allocation_policy.services_secondary_range_name
      stack_type                    = var.ip_allocation_policy.stack_type
    }
  }

  dynamic "maintenance_policy" {
    for_each = var.maintenance_policy != null ? [""] : []

    content {
      recurring_window {
        end_time   = var.maintenance_policy.recurring_window.end_time
        recurrence = var.maintenance_policy.recurring_window.recurrence
        start_time = var.maintenance_policy.recurring_window.start_time
      }

      dynamic "maintenance_exclusion" {
        for_each = coalesce(var.maintenance_policy.exclusions, [])

        content {
          end_time       = maintenance_exclusion.value.end_time
          exclusion_name = maintenance_exclusion.value.name
          start_time     = maintenance_exclusion.value.start_time

          dynamic "exclusion_options" {
            for_each = maintenance_exclusion.value.scope != null ? [""] : []

            content {
              scope = maintenance_exclusion.value.scope
            }
          }
        }
      }
    }
  }

  # By default we do not want to issue a client certificate to authenticate to
  # the cluster endpoint. This is because the certificate is not automatically
  # rotated and therefore is a security risk.
  master_auth {
    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  # Provide more control over automatic upgrades by specifying a release
  # channel. See
  # https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels
  dynamic "release_channel" {
    for_each = var.kubernetes_version_release_channel != null ? [""] : []

    content {
      channel = var.kubernetes_version_release_channel
    }
  }

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }
}
