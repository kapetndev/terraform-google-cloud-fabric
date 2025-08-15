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
  source                        = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/gke_cluster?ref=v0.1.0"
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
| [google_container_cluster.kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [random_id.cluster_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [google_container_engine_versions.supported](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/container_engine_versions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes master version. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Compute zone or region the cluster master nodes will sit in. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name of the cluster. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name or `self_link` of the Google Compute Engine network to which the cluster is connected. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Name or `self_link` of the Google Compute Engine subnetwork in which the cluster's instances are launched. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | A brief description of this resource. | `string` | `null` | no |
| <a name="input_descriptive_name"></a> [descriptive\_name](#input\_descriptive\_name) | The authoritative name of the cluster. Used instead of `name` variable. | `string` | `null` | no |
| <a name="input_enable_intranode_visibility"></a> [enable\_intranode\_visibility](#input\_enable\_intranode\_visibility) | Enable Intra-node visibility for the cluster. | `bool` | `false` | no |
| <a name="input_enable_vertical_pod_autoscaling"></a> [enable\_vertical\_pod\_autoscaling](#input\_enable\_vertical\_pod\_autoscaling) | Enable vertical pod autoscaling. | `bool` | `true` | no |
| <a name="input_ip_allocation_policy"></a> [ip\_allocation\_policy](#input\_ip\_allocation\_policy) | Configuration for cluster IP allocation.<br/><br/>(Optional) cluster\_ipv4\_cidr\_block - The IP address range for the cluster pod IPs. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use.<br/>(Optional) cluster\_secondary\_range\_name - The name of the existing secondary range in the cluster's subnetwork to use for pod IP addresses. Alternatively, `cluster_ipv4_cidr_block` can be used to automatically create a GKE-managed one.<br/>(Optional) services\_ipv4\_cidr\_block - The IP address range of the services IPs in this cluster. Set to blank to have a range chosen with the default size. Set to /netmask (e.g. /14) to have a range chosen with a specific netmask. Set to a CIDR notation (e.g. 10.96.0.0/14) from the RFC-1918 private networks (e.g. 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) to pick a specific range to use.<br/>(Optional) services\_secondary\_range\_name - The name of the existing secondary range in the cluster's subnetwork to use for service `ClusterIP`s. Alternatively, `services_ipv4_cidr_block` can be used to automatically create a GKE-managed one.<br/>(Optional) stack\_type - The IP Stack Type of the cluster. Default value is `IPV4`. Possible values are `IPV4` and `IPV4_IPV6`. | <pre>object({<br/>    cluster_ipv4_cidr_block       = optional(string)<br/>    cluster_secondary_range_name  = optional(string)<br/>    services_ipv4_cidr_block      = optional(string)<br/>    services_secondary_range_name = optional(string)<br/>    stack_type                    = optional(string, "IPV4")<br/>  })</pre> | `null` | no |
| <a name="input_issue_client_certificate"></a> [issue\_client\_certificate](#input\_issue\_client\_certificate) | Issue a client certificate to authenticate to the cluster endpoint. | `bool` | `false` | no |
| <a name="input_kubernetes_version_release_channel"></a> [kubernetes\_version\_release\_channel](#input\_kubernetes\_version\_release\_channel) | Kubernetes master version release channel. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | User defined labels to assign to the cluster. | `map(any)` | `{}` | no |
| <a name="input_maintenance_policy"></a> [maintenance\_policy](#input\_maintenance\_policy) | The maintenance policy to use for the cluster.<br/><br/>(Required) recurring\_window - Time window for recurring maintenance operations.<br/>(Required) recurring\_window.end\_time - Time for the (initial) recurring maintenance to end in RFC3339 format. This value is also used to calculte duration of the maintenance window.<br/>(Required) recurring\_window.start\_time - Time for the (initial) recurring maintenance to start in RFC3339 format.<br/>(Optional) recurring\_window.recurrence - RRULE recurrence rule for the recurring maintenance window specified in RFC5545 format. This value is used to compute the start time of subsequent windows.<br/><br/>(Optional) exclusions - Exceptions to maintenance window. Non-emergency maintenance should not occur in these windows. A cluster can have up to three maintenance exclusions at a time.<br/>(Required) exclusions.end\_time - Time for the maintenance exclusion to end in RFC3339 format.<br/>(Required) exclusions.name - Human-readable description of the maintenance exclusion. This field is for display purposes only.<br/>(Required) exclusions.start\_time - Time for the maintenance exclusion to start in RFC3339 format.<br/>(Optional) exclusions.scope - The scope of the maintenance exclusion. Possible values are `NO_UPGRADES`, `NO_MINOR_UPGRADES`, and `NO_MINOR_OR_NODE_UPGRADES`. | <pre>object({<br/>    recurring_window = object({<br/>      end_time   = string<br/>      recurrence = optional(string, "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH")<br/>      start_time = string<br/>    })<br/>    exclusions = optional(list(object({<br/>      end_time   = string<br/>      name       = string<br/>      scope      = optional(string)<br/>      start_time = string<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix used to generate the cluster name. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |
| <a name="input_security_group"></a> [security\_group](#input\_security\_group) | The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format `gke-security-groups@yourdomain.com`. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Base64 encoded public certificate that is the root of trust for the cluster. |
| <a name="output_name"></a> [name](#output\_name) | Kubernetes cluster name. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
