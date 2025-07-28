# Google Kubernetes Engine Node Pool

Terraform module to create and manage Kubernetes node pools.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "kubernetes_cluster_node_pool_production" {
  source    = "git::https://github.com/kapetndev/terraform-google-compute.git//modules/gke_node_pool?ref=v0.1.0"
  cluster   = "my-cluster"
  location  = "europe-west2"
  pool_name = "my-pool"
}
```

## Examples

- [kubernetes-cluster](../../examples/kubernetes-cluster) - Create a Kubernetes
  cluster and separately managed node pool.

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.71.0 |
| [random](https://registry.terraform.io/providers/hashicorp/random/latest) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [`google_container_node_pool.container_optimised_node_pool`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [`random_id.node_pool_name`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster` | The cluster to create the node pool for. Cluster must be present in `location` provided for clusters. May be specified in the format `projects/{{project}}/locations/{{location}}/clusters/{{cluster}}` or as just the name of the cluster | `string` | | yes |
| `location` | The location (region or zone) of the cluster. This will also be the location the node pool will be created | `string` | | yes |
| `name` | The name of the Google Compute node pool | `string` | | yes |
| `autoscaling` | Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage | `object{...}` | `{}` | no |
| `autoscaling.max_node_count` | Maximum number of nodes per zone in the node pool| `number` | `3` | no |
| `autoscaling.min_node_count` | Minimum number of nodes per zone in the node pool| `number` | `1` | no |
| `descriptive_name` | The authoritative name of the node pool. Used instead of `name` variable | `string` | `null` | no |
| `management` | Node management configuration | `object{...}` | `{}` | no |
| `management.auto_repair` | Whether the nodes will be automatically repaired | `bool` | `true` | no |
| `management.auto_upgrade` | Whether the nodes will be automatically upgraded | `bool` | `true` | no |
| `max_pods_per_node` | Maximum number of pods per node in the node pool | `number` | `110` | no |
| `node_config` | Parameters used in creating the node pool | `object{...}` | `{}` | no |
| `node_config.disk_size` | The size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB | `number` | `100` | no |
| `node_config.disk_type` | The type of disk attached to each node. Possible values are `pd-standard` and `pd-ssd` | `string` | `pd-ssd` | no |
| `node_config.image_type` | The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool | `string` | `COS_CONTAINERD` | no |
| `node_config.labels` | The Kubernetes labels (key/value pairs) to be applied to each node. The kubernetes.io/ and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified | `map(string)` | `null` | no |
| `node_config.machine_type` | The name of a Google Compute Engine machine type | `string` | `e2-medium` | no |
| `node_config.metadata` | The metadata (key/value pairs) assigned to instances in the cluster | `map(string)` | `{}` | no |
| `node_config.oauth_scopes` | The set of Google API scopes to be made available on all of the node VMs under the "default" service account | `set(string)` | `[]` | no |
| `prefix` | An optional prefix used to generate the node pool name | `string` | `null` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
| `upgrade_settings` | Node upgrade settings to change how GKE upgrades nodes | `object{...}` | `{}` | no |
| `upgrade_settings.max_surge` | The number of additional nodes that can be added to the node pool during an upgrade | `number` | `1` | no |
| `upgrade_settings.max_unavailable` | The number of nodes that can be simultaneously unavailable during an upgrade | `number` | `0` | no |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Node pool name |
