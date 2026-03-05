# Google Kubernetes Engine Node Pool

Terraform module to create and manage GKE node pools with autoscaling
capabilities, defining per-zone minimum and maximum node counts. Nodes benefit
from automatic repair and upgrades with configurable surge settings during
updates.

Nodes run Container-Optimised OS with shielded VM security features and default
GCP monitoring scopes, whilst legacy metadata endpoints are disabled to prevent
SSRF attacks against the GKE metadata API.

## Usage

```hcl
module "kubernetes_cluster" {
  source                       = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/gke_cluster?ref=v0.1.0"
  location                     = "europe-west2"
  name                         = "my-cluster"
  network                      = module.vpc.name
  subnetwork                   = module.vpc.subnets["europe-west2/my-vpc"].self_link
  kubernetes_release_channel   = "REGULAR"
  workload_identity_project_id = "my-project"

  ip_allocation_policy = {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }
}

module "node_pool" {
  source          = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/gke_node_pool?ref=v0.1.0"
  cluster         = module.kubernetes_cluster.name
  location        = "europe-west2"
  name            = "general"
  service_account = "gke-nodes-sa@my-project.iam.gserviceaccount.com"
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.60.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.60.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_container_node_pool.container_optimised_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [random_id.node_pool_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | The cluster to attach the node pool to. May be specified as a short name or as the fully qualified resource ID in the format `projects/PROJECT/locations/LOCATION/clusters/CLUSTER`. The cluster must exist in the same location as the node pool. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The region or zone of the cluster. For regional clusters, nodes are spread across all zones within the region. For zonal clusters, nodes are placed in that single zone. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the node pool. Used as a prefix for the generated pool name unless `descriptive_name` is set. | `string` | n/a | yes |
| <a name="input_service_account"></a> [service\_account](#input\_service\_account) | The email of the GCP service account to assign to the nodes in this pool. The<br/>nodes use this identity for GCP API calls such as pulling images from Artifact<br/>Registry, writing logs, and writing metrics.<br/><br/>A dedicated, minimal service account should always be created and provided<br/>here. Do not use the Compute Engine default service account<br/>(PROJECT\_NUMBER-compute@developer.gserviceaccount.com) — it has project-wide<br/>editor permissions and represents a significant privilege escalation risk if a<br/>node is compromised.<br/><br/>The service account must be granted the following roles at minimum:<br/>  - roles/logging.logWriter<br/>  - roles/monitoring.metricWriter<br/>  - roles/monitoring.viewer<br/>  - roles/artifactregistry.reader  (or roles/storage.objectViewer for GCR)<br/><br/>When Workload Identity Federation is active (`workload_metadata_config =<br/>GKE_METADATA`, which is the default), the node service account credentials are<br/>not accessible to Pod workloads. Pods authenticate to GCP via their Kubernetes<br/>service account tokens instead. | `string` | n/a | yes |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Cluster autoscaler configuration. Controls the per-zone minimum and maximum node<br/>counts. The autoscaler scales within these bounds in response to Pod scheduling<br/>pressure.<br/><br/>(Optional) min\_node\_count - Minimum number of nodes per zone. Defaults to 1.<br/>(Optional) max\_node\_count - Maximum number of nodes per zone. Defaults to 3. | <pre>object({<br/>    max_node_count = optional(number, 3)<br/>    min_node_count = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | Fully qualified, authoritative name of the node pool. When set, `name` is ignored and this value is used directly with no suffix appended. | `string` | `null` | no |
| <a name="input_management"></a> [management](#input\_management) | Automatic node repair and upgrade configuration. Defaults to both enabled, which<br/>is strongly recommended. Disabling auto\_upgrade means you become responsible for<br/>keeping nodes in sync with the control plane version.<br/><br/>(Optional) auto\_repair - Automatically repair unhealthy nodes. Defaults to true.<br/>(Optional) auto\_upgrade - Automatically upgrade nodes when a new node version is available within the cluster's release channel. Defaults to true. | <pre>object({<br/>    auto_repair  = optional(bool, true)<br/>    auto_upgrade = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_max_pods_per_node"></a> [max\_pods\_per\_node](#input\_max\_pods\_per\_node) | Maximum number of Pods that can be scheduled on a single node. Affects the size of the Pod CIDR allocated per node. Reducing this value allows more nodes to share a given IP range. Cannot be changed after the node pool is created. | `number` | `110` | no |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Node VM configuration. All fields are optional with secure, cost-conscious<br/>defaults.<br/><br/>(Optional) disk\_size - Boot disk size in GB. Minimum 10GB. Defaults to 100GB.<br/>(Optional) disk\_type - Boot disk type. Must be one of `pd-standard`, `pd-ssd`, `pd-balanced`, or `pd-extreme`. Defaults to `pd-ssd` for consistent IOPS.<br/>(Optional) image\_type - Node OS image. Must be one of `COS_CONTAINERD` or `UBUNTU_CONTAINERD`. Defaults to `COS_CONTAINERD` (Container-Optimised OS), which is hardened and maintained by Google. Changing this value recreates all nodes in the pool.<br/>(Optional) labels - Kubernetes node labels applied to each node. The `kubernetes.io/` and `k8s.io/` prefixes are reserved and cannot be used.<br/>(Optional) machine\_type - Compute Engine machine type. Defaults to `e2-medium`. Choose based on your workload's CPU and memory requirements.<br/>(Optional) metadata - GCE instance metadata key/value pairs. Merged with the module's required security metadata — caller-supplied values take precedence for non-reserved keys.<br/>(Optional) oauth\_scopes - Additional GCP API OAuth scopes granted to the node service account. Merged with the module's required baseline scopes. | <pre>object({<br/>    disk_size    = optional(number, 100)<br/>    disk_type    = optional(string, "pd-ssd")<br/>    image_type   = optional(string, "COS_CONTAINERD")<br/>    labels       = optional(map(string))<br/>    machine_type = optional(string, "e2-medium")<br/>    metadata     = optional(map(string), {})<br/>    oauth_scopes = optional(set(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix prepended to `name` when generating the node pool name. Has no effect when `descriptive_name` is set. Cannot be an empty string — use null to omit. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project in which to create the node pool. Defaults to the provider project if not set. | `string` | `null` | no |
| <a name="input_upgrade_settings"></a> [upgrade\_settings](#input\_upgrade\_settings) | Controls how GKE replaces nodes during upgrades. The default configuration adds<br/>one surge node before taking a node offline, ensuring zero downtime.<br/><br/>(Optional) max\_surge - Number of additional nodes provisioned during an upgrade. Higher values speed up upgrades at the cost of temporary extra capacity. Defaults to 1.<br/>(Optional) max\_unavailable - Number of nodes that may be simultaneously unavailable during an upgrade. Setting this above 0 risks disrupting workloads without Pod Disruption Budgets. Defaults to 0. | <pre>object({<br/>    max_surge       = optional(number, 1)<br/>    max_unavailable = optional(number, 0)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Fully qualified node pool ID in the format projects/PROJECT/locations/LOCATION/clusters/CLUSTER/nodePools/NAME. |
| <a name="output_name"></a> [name](#output\_name) | The name of the node pool as known to the GKE API. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
