# Google Kubernetes Engine Node Pool

Terraform module to create and manage Kubernetes node pools.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "kubernetes_cluster_node_pool_production" {
  source    = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/gke_node_pool?ref=v0.1.0"
  cluster   = "my-cluster"
  location  = "europe-west2"
  pool_name = "my-pool"
}
```

## Examples

- [kubernetes-cluster](../../examples/kubernetes-cluster) - Create a Kubernetes
  cluster and separately managed node pool.

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.14.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.14.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_container_node_pool.container_optimised_node_pool](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_node_pool) | resource |
| [random_id.node_pool_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster"></a> [cluster](#input\_cluster) | The cluster to create the node pool for. Cluster must be present in `location` provided for clusters. May be specified in the format `projects/{{project}}/locations/{{location}}/clusters/{{cluster}}` or as just the name of the cluster. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location (region or zone) of the cluster. This will also be the location the node pool will be created. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Google Compute node pool | `string` | n/a | yes |
| <a name="input_autoscaling"></a> [autoscaling](#input\_autoscaling) | Configuration required by cluster autoscaler to adjust the size of the node pool to the current cluster usage.<br/><br/>(Optional) max\_node\_count - Maximum number of nodes per zone in the node pool.<br/>(Optional) min\_node\_count - Minimum number of nodes per zone in the node pool. | <pre>object({<br/>    max_node_count = optional(number, 3)<br/>    min_node_count = optional(number, 1)<br/>  })</pre> | `{}` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | The authoritative name of the node pool. Used instead of `name` variable. | `string` | `null` | no |
| <a name="input_management"></a> [management](#input\_management) | Node management configuration<br/><br/>(Optional) auto\_repair - Whether the nodes will be automatically repaired.<br/>(Optional) auto\_upgrade - Whether the nodes will be automatically upgraded. | <pre>object({<br/>    auto_repair  = optional(bool, true)<br/>    auto_upgrade = optional(bool, true)<br/>  })</pre> | `{}` | no |
| <a name="input_max_pods_per_node"></a> [max\_pods\_per\_node](#input\_max\_pods\_per\_node) | Maximum number of pods per node in the node pool. | `number` | `110` | no |
| <a name="input_node_config"></a> [node\_config](#input\_node\_config) | Parameters used in creating the node pool.<br/><br/>(Optional) disk\_size - The size of the disk attached to each node, specified in GB. The smallest allowed disk size is 10GB. Default value is 100GB.<br/>(Optional) disk\_type - The type of disk attached to each node. Default value is `pd-ssd`. Possible values are `pd-standard` and `pd-ssd`.<br/>(Optional) image\_type - The image type to use for this node. Note that changing the image type will delete and recreate all nodes in the node pool. Default value is `COS_CONTAINERD`.<br/>(Optional) labels - The Kubernetes labels (key/value pairs) to be applied to each node. The kubernetes.io/ and k8s.io/ prefixes are reserved by Kubernetes Core components and cannot be specified.<br/>(Optional) machine\_type - The name of a Google Compute Engine machine type. Default value is `e2-medium`.<br/>(Optional) metadata - The metadata (key/value pairs) assigned to instances in the cluster.<br/>(Optional) oauth\_scopes - The set of Google API scopes to be made available on all of the node VMs under the "default" service account. | <pre>object({<br/>    disk_size    = optional(number, 100)<br/>    disk_type    = optional(string, "pd-ssd")<br/>    image_type   = optional(string, "COS_CONTAINERD")<br/>    labels       = optional(map(string))<br/>    machine_type = optional(string, "e2-medium")<br/>    metadata     = optional(map(string), {})<br/>    oauth_scopes = optional(set(string), [])<br/>  })</pre> | `{}` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix used to generate the node pool name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_upgrade_settings"></a> [upgrade\_settings](#input\_upgrade\_settings) | Node upgrade settings to change how GKE upgrades nodes.<br/><br/>(Optional) max\_surge - The number of additional nodes that can be added to the node pool during an upgrade.<br/>(Optional) max\_unavailable - The number of nodes that can be simultaneously unavailable during an upgrade. | <pre>object({<br/>    max_surge       = optional(number, 1)<br/>    max_unavailable = optional(number, 0)<br/>  })</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_name"></a> [name](#output\_name) | Node pool name. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
