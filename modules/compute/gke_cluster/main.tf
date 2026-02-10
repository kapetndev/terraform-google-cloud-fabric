locals {
  # When not using a verbatim name, we generate a random ID to use as the suffix
  # for the cluster name. This is to ensure that the name is unique and does not
  # conflict with any other cluster in the project. An optional prefix can be
  # added to the name, which is useful for grouping clusters.
  name   = "${local.prefix}${var.name}"
  prefix = var.prefix != null ? "${var.prefix}-" : ""

  # min_master_version is only set when managing the version explicitly. When a
  # release channel is active, GKE owns the version and setting this attribute
  # causes perpetual plan diffs as the cluster is upgraded through the channel.
  min_master_version = var.kubernetes_release_channel == null ? var.kubernetes_version : null
}

resource "random_id" "cluster_name" {
  count       = var.descriptive_name == null ? 1 : 0
  byte_length = 4
  prefix      = "${local.name}-"
}

resource "google_container_cluster" "kubernetes_cluster" {
  description        = var.description
  location           = var.location
  min_master_version = local.min_master_version
  name               = coalesce(var.descriptive_name, random_id.cluster_name[0].hex)
  network            = var.network
  project            = var.project_id
  resource_labels    = var.labels
  subnetwork         = var.subnetwork

  # GKE Dataplane V2 replaces kube-proxy and iptables-based network policy
  # enforcement with eBPF via Cilium. This implicitly enables NetworkPolicy
  # enforcement without requiring a separate addon. Note: this can only be set
  # at cluster creation time and cannot be changed without recreating the
  # cluster.
  datapath_provider = var.datapath_provider

  # Expose Pod-to-Pod intranode traffic to the VPC for flow logging. Disabled
  # by default due to minor performance overhead.
  enable_intranode_visibility = var.enable_intranode_visibility

  # It is not possible to create a cluster without a node pool, but managing the
  # default node pool is not recommended. Create the smallest possible default
  # pool and delete it immediately — node pools are managed separately via the
  # gke_node_pool module.
  #
  # This is intentionally not configurable.
  initial_node_count       = 1
  remove_default_node_pool = true

  # Route all logging and monitoring data to Google Cloud's managed services.
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"

  # Addon configuration. horizontal_pod_autoscaling and http_load_balancing are
  # enabled unconditionally as they are foundational to GKE's operation and
  # disabling them is not a supported configuration in this module. Both are GKE
  # defaults and are included here for explicit documentation purposes.
  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }
  }

  # Google Groups integration for Kubernetes role-based access control
  # (RBAC). Only rendered when a security group is provided — the block must be
  # entirely absent when not in use, so a dynamic block is required here.
  dynamic "authenticator_groups_config" {
    for_each = var.security_group != null ? [""] : []

    content {
      security_group = var.security_group
    }
  }

  # VPC-native networking via alias IPs. The block must be absent entirely for
  # routes-based clusters, so a dynamic block is used. Absent when null.
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

  # Maintenance window and exclusions. The block is absent when no policy is
  # configured, allowing GKE to schedule maintenance at any time.
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

  # Disable client certificate issuance by default. Client certificates are not
  # automatically rotated and represent a long-lived credential risk. Use
  # short-lived tokens or Workload Identity for authentication instead.
  master_auth {
    client_certificate_config {
      issue_client_certificate = var.issue_client_certificate
    }
  }

  # Master endpoint access controls. This block is absent when private endpoint
  # access is enabled, as the control plane is not accessible via the public
  # internet in that configuration. When present, the block allows the control
  # plane to be accessed over the public internet but restricts access to a
  # specified set of CIDR blocks.
  #
  # If private access is not achieveble immediately then the control plane
  # should be restricted to a limited set of CIDR blocks and the cluster should
  # be migrated to private access as soon as possible.
  #
  # The cleanest solution to private access is to enable IAP on the project and
  # have operators tunnel requests through a secure tunnel. This offers the most
  # transparent and secure solution.
  #
  # The control plane is set to public access by default.
  dynamic "master_authorized_networks_config" {
    for_each = !var.private_cluster.enable_private_endpoint ? [""] : []

    content {
      gcp_public_cidrs_access_enabled = var.enable_gcp_public_access

      dynamic "cidr_blocks" {
        for_each = coalesce(var.master_authorized_networks, [])

        content {
          cidr_block   = cidr_blocks.value.cidr_block
          display_name = cidr_blocks.value.display_name
        }
      }
    }
  }

  # Private cluster configuration. Rendered unconditionally — private cluster
  # behaviour is controlled by the field values within the block. Nodes receive
  # only internal IP addresses when enable_private_nodes is true, which is the
  # default.
  private_cluster_config {
    enable_private_nodes    = var.private_cluster.enable_private_nodes
    enable_private_endpoint = var.private_cluster.enable_private_endpoint
    master_ipv4_cidr_block  = var.private_cluster.master_ipv4_cidr_block
  }

  # Release channel controls automatic version management. The block must be
  # absent when managing the version explicitly via kubernetes_version, because
  # an empty or UNSPECIFIED channel combined with min_master_version produces
  # undefined behaviour. See
  # https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels
  dynamic "release_channel" {
    for_each = var.kubernetes_release_channel != null ? [""] : []

    content {
      channel = var.kubernetes_release_channel
    }
  }

  vertical_pod_autoscaling {
    enabled = var.enable_vertical_pod_autoscaling
  }

  # Workload Identity Federation enables Pods to authenticate to GCP APIs using
  # short-lived tokens bound to Kubernetes service accounts, rather than using
  # the node's long-lived service account credentials. This is the recommended
  # authentication mechanism for workloads running on GKE.
  #
  # The workload pool is always derived from the project ID using GKE's
  # canonical format. It is intentionally not configurable — there is only one
  # valid value for a given project.
  #
  # Enabling this requires project_id to be explicitly set. When project_id is
  # null the provider project is used for the cluster resource itself, but
  # Terraform cannot interpolate that implicit value here.
  dynamic "workload_identity_config" {
    for_each = var.workload_identity_project_id != null ? [""] : []

    content {
      workload_pool = "${var.workload_identity_project_id}.svc.id.goog"
    }
  }

  lifecycle {
    precondition {
      condition     = (var.descriptive_name == null) != (var.name == null)
      error_message = "name: exactly one of `name` or `descriptive_name` must be set."
    }
    # Enforce mutual exclusivity of release_channel and kubernetes_version.
    precondition {
      condition     = (var.kubernetes_release_channel == null) != (var.kubernetes_version == null)
      error_message = "version: exactly one of `kubernetes_release_channel` (recommended) or `kubernetes_version` must be set. Set the other to null."
    }
    precondition {
      condition     = !var.private_cluster.enable_private_nodes || var.ip_allocation_policy != null
      error_message = "private_cluster: `ip_allocation_policy` must be set when `enable_private_nodes` is true. Private clusters require VPC-native networking."
    }
  }
}

resource "google_compute_firewall" "master_to_node_webhooks" {
  # Only created for private clusters. On non-private clusters the control plane
  # is not peered into the VPC and GKE manages its own firewall rules.
  count = var.private_cluster.enable_private_nodes ? 1 : 0

  name        = "${google_container_cluster.kubernetes_cluster.name}-master-webhooks"
  network     = var.network
  project     = var.project_id
  description = "Allow the GKE control plane to reach admission webhook endpoints on nodes. Required for any MutatingWebhookConfiguration or ValidatingWebhookConfiguration installed in the cluster, including Istio, cert-manager, Kyverno, and Gatekeeper."

  allow {
    protocol = "tcp"
    ports    = var.private_cluster.master_exposed_webhook_ports
  }

  source_ranges = [
    google_container_cluster.kubernetes_cluster.private_cluster_config[0].master_ipv4_cidr_block
  ]

  # Target nodes by the cluster-scoped network tag GKE automatically applies
  # to all nodes in the cluster. This is more precise than targeting all nodes
  # in the network and avoids the rule applying to unrelated VMs.
  target_tags = ["gke-${google_container_cluster.kubernetes_cluster.name}"]
}
