# Google Kubernetes Engine Cluster

Terraform module to create and manage Kubernetes clusters.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
data "google_compute_network" "my_vpc" {
  name = "my-vpc"
}

data "google_compute_subnetwork" "my_vpc_europe_west2" {
  name   = "my-vpc"
  region = "europe-west2"
}

module "kubernetes_cluster" {
  source                        = "git::https://github.com/kapetndev/terraform-google-compute.git//modules/gke_cluster?ref=v0.1.0"
  cluster_secondary_range_name  = "gke-cluster-pods"
  kubernetes_version            = "1.24.12-gke.500"
  location                      =  "europe-west2"
  name                          = "my-cluster"
  network                       = data.google_compute_network.my_vpc.id
  services_secondary_range_name = "gke-cluster-services"
  subnetwork                    = data.google_compute_subnetwork_my_vpc_europe_west2.id
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
| [`google_container_cluster.kubernetes_clusters`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [`google_container_engine_versions.supported`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_engine_versions) | data source |
| [`random_id.cluster_name`](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `kubernetes_version` | Kubernetes master version | `string` | | yes |
| `location` | Compute zone or region the cluster master nodes will sit in | `string` | | yes |
| `name` | Name of the cluster | `string` | | yes |
| `network` | Name or `self_link` of the Google Compute Engine network to which the cluster is connected | `string` | | yes |
| `subnetwork` | Name or `self_link` of the Google Compute Engine subnetwork in which the cluster's instances are launched | `string` | | yes |
| `description` | A brief description of this resource | string | `null` | no |
| `descriptive_name` | The authoritative name of the cluster. Used instead of `name` variable | `string` | `null` | no |
| `enable_intranode_visability` | Enable Intra-node visibility for the cluster | `bool` | `false` | no |
| `enable_vertical_pod_autoscaling` | Enable vertical pod autoscaling | `bool` | `true` | no |
| `ip_allocation_policy` | Configuration for cluster IP allocations | `object{...}` | `null` | no |
| `ip_allocation_policy.cluster_ipv4_cidr_block` | The IP address range for the cluster pod IPs. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use | `string` | `null` | no |
| `ip_allocation_policy.cluster_secondary_range_name` | The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. Alternatively, `cluster_ipv4_cidr_block` can be used to automatically create a GKE-managed one | `string` | `null` | no |
| `ip_allocation_policy.services_ipv4_cidr_block` | The IP address range of the services IPs in this cluster. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use | `string` | `null` | no |
| `ip_allocation_policy.services_secondary_range_name` | The name of the existing secondary range in the cluster's subnetwork to use for service `ClusterIP`s. Alternatively, `services_ipv4_cidr_block` can be used to automatically create a GKE-managed one | `string` | `null` | no |
| `ip_allocation_policy.stack_type` | The IP Stack Type of the cluster. Default value is `IPV4`. Possible values are `IPV4` and `IPV4_IPV6` | `string` | `IPV4` | no |
| `issue_client_certificate` | Issue a client certificate to authenticate to the cluster endpoint | `bool` | `false` | no |
| `kubernetes_version_release_channel` | Kubernetes master version release channel | `string` | `null` | no |
| `labels` | User defined labels to assign to the cluster | `map(string)` | `{}` | no |
| `maintenance_policy` | The maintenance policy to use for the cluster | `object{...}` | `null` | no |
| `maintenance_policy.recurring_window` | The window for recurring maintenance operations | `object{...}` | | yes |
| `maintenance_policy.recurring_window.end_time` | Time for the (initial) recurring maintenance to end in RFC3339 format. This value is also used to calculte duration of the maintenance window | `string` | | yes |
| `maintenance_policy.recurring_window.start_time` | Time for the (initial) recurring maintenance to start in RFC3339 format | `string` | | yes |
| `maintenance_policy.recurring_window.recurrence` | RRULE recurrence rule for the recurring maintenance window specified in RFC5545 format. This value is used to compute the start time of subsequent windows | `string` | `FREQ=WEEKLY;BYDAY=MO,TU,WE,TH` | no |
| `maintenance_policy.exclusions` | Exceptions to maintenance window. Non-emergency maintenance should not occur in these windows. A cluster can have up to three maintenance exclusions at a time | `list(object{...})` | `null` | no |
| `maintenance_policy.exclusions[*].end_time` | Time for the maintenance exclusion to end in RFC3339 format | `string` | | yes |
| `maintenance_policy.exclusions[*].name` | Human-readable description of the maintenance exclusion. This field is for display purposes only | `string` | | yes |
| `maintenance_policy.exclusions[*].start_time` | Time for the maintenance exclusion to start in RFC3339 format | `string` | | yes |
| `maintenance_policy.exclusions[*].scope` | The scope of the maintenance exclusion. Possible values are `NO_UPGRADES`, `NO_MINOR_UPGRADES`, and `NO_MINOR_OR_NODE_UPGRADES` | `string` | `null` | no |
| `prefix` | An optional prefix used to generate the cluster name | `string` | `null` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
| `security_group` | The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format `gke-security-groups@yourdomain.com` | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `name` | Kubernetes cluster name |
| `cluster_ca_certificate` | Base64 encoded public certificate that is the root of trust for the cluster |
