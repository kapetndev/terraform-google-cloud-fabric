# Google Kubernetes Engine Cluster

Terraform module to create and manage GKE clusters with Kubernetes versions
managed through release channels or pinned to specific versions. Clusters
support alias IP addressing for pod and service networks, optional IPv6 stack
types, and Google Groups integration for RBAC.

## Usage

```hcl
module "vpc" {
  source = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/vpc_network?ref=v0.1.0"
  name   = "my-vpc"

  subnets = [
    {
      name          = "my-vpc"
      region        = "europe-west2"
      ip_cidr_range = "10.0.0.0/24"

      secondary_ip_ranges = [
        { range_name = "gke-pods",     ip_cidr_range = "10.1.0.0/16" },
        { range_name = "gke-services", ip_cidr_range = "10.2.0.0/20" },
      ]
    },
  ]
}

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
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.14.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 6.14.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.1 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.master_to_node_webhooks](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_container_cluster.kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) | resource |
| [random_id.cluster_name](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | The region or zone in which to create the cluster. A region creates a regional (multi-zone) cluster; a zone creates a zonal cluster. | `string` | n/a | yes |
| <a name="input_network"></a> [network](#input\_network) | Name or `self_link` of the VPC network to which the cluster is connected. | `string` | n/a | yes |
| <a name="input_subnetwork"></a> [subnetwork](#input\_subnetwork) | Name or `self_link` of the VPC subnetwork in which the cluster nodes are launched. | `string` | n/a | yes |
| <a name="input_datapath_provider"></a> [datapath\_provider](#input\_datapath\_provider) | The datapath provider for the cluster. Controls packet processing and<br/>NetworkPolicy enforcement. Cannot be changed after cluster creation without<br/>recreating the cluster.<br/><br/>`ADVANCED_DATAPATH` (default) - GKE Dataplane V2. Uses eBPF via Cilium,<br/>replacing kube-proxy and iptables. Provides built-in NetworkPolicy enforcement,<br/>better scalability at high Service counts, and richer observability via Hubble.<br/>Compatible with OSS Istio using the CNI plugin installation profile.<br/><br/>`LEGACY_DATAPATH` - Traditional iptables/kube-proxy dataplane. Use only when<br/>compatibility with tooling that directly inspects iptables rules is required. | `string` | `"ADVANCED_DATAPATH"` | no |
| <a name="input_description"></a> [description](#input\_description) | A human-readable description of the cluster resource. | `string` | `null` | no |
| <a name="input_enable_gcp_public_access"></a> [enable\_gcp\_public\_access](#input\_enable\_gcp\_public\_access) | Permit access to the master endpoint from GCP's public IP ranges. Defaults to false. Takes effect only when `master_authorized_networks` is configured. | `bool` | `false` | no |
| <a name="input_enable_intranode_visibility"></a> [enable\_intranode\_visibility](#input\_enable\_intranode\_visibility) | Send Pod-to-Pod traffic within a node through the VPC, making it visible to VPC flow logs and subject to firewall rules. Incurs a minor performance overhead. Recommended when detailed network observability is required. | `bool` | `false` | no |
| <a name="input_enable_vertical_pod_autoscaling"></a> [enable\_vertical\_pod\_autoscaling](#input\_enable\_vertical\_pod\_autoscaling) | Enable the Vertical Pod Autoscaler (VPA), which automatically adjusts Pod resource requests based on historical usage. Defaults to true. | `bool` | `true` | no |
| <a name="input_ip_allocation_policy"></a> [ip\_allocation\_policy](#input\_ip\_allocation\_policy) | VPC-native IP allocation configuration for Pod and Service networking. When null<br/>the cluster uses routes-based networking, which is not recommended for new<br/>clusters and is required to be set for private clusters.<br/><br/>(Optional) cluster\_ipv4\_cidr\_block - CIDR range for Pod IPs. Specify either this or `cluster_secondary_range_name`, not both.<br/>(Optional) cluster\_secondary\_range\_name - Existing secondary range in the subnetwork to use for Pod IPs.<br/>(Optional) services\_ipv4\_cidr\_block - CIDR range for Service ClusterIPs. Specify either this or `services_secondary_range_name`, not both.<br/>(Optional) services\_secondary\_range\_name - Existing secondary range in the subnetwork to use for Service ClusterIPs.<br/>(Optional) stack\_type - `IPV4` (default) or `IPV4_IPV6` for dual-stack clusters. | <pre>object({<br/>    cluster_ipv4_cidr_block       = optional(string)<br/>    cluster_secondary_range_name  = optional(string)<br/>    services_ipv4_cidr_block      = optional(string)<br/>    services_secondary_range_name = optional(string)<br/>    stack_type                    = optional(string, "IPV4")<br/>  })</pre> | `{}` | no |
| <a name="input_issue_client_certificate"></a> [issue\_client\_certificate](#input\_issue\_client\_certificate) | Issue a client certificate to authenticate to the cluster endpoint. | `bool` | `false` | no |
| <a name="input_kubernetes_release_channel"></a> [kubernetes\_release\_channel](#input\_kubernetes\_release\_channel) | GKE release channel for automatic version management. When set, GKE selects and<br/>upgrades the control plane version automatically. Mutually exclusive with<br/>`kubernetes_version` — exactly one must be set.<br/><br/>`RAPID` - Latest releases, first to receive patches and new features. Suitable for dev/staging environments.<br/>`REGULAR` - Releases after validation in RAPID. Recommended for most production clusters.<br/>`STABLE` - Most conservative cadence. Suitable for business-critical workloads with strict stability requirements.<br/>`UNSPECIFIED` - Opts out of automatic channel management. Not recommended. | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Explicit Kubernetes master version, e.g. "1.29.5-gke.1234". Mutually exclusive<br/>with `kubernetes_release_channel` — exactly one must be set. When a release<br/>channel is active, GKE manages the version and this variable must be null.<br/><br/>Use `gcloud container get-server-config --location=LOCATION` to list available<br/>versions for a given location. | `string` | `null` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | User defined resource labels to assign to the cluster. | `map(string)` | `{}` | no |
| <a name="input_maintenance_policy"></a> [maintenance\_policy](#input\_maintenance\_policy) | Maintenance window and exclusion configuration. When null, GKE may perform<br/>maintenance at any time. Recommended for production clusters to constrain when<br/>upgrades and repairs occur.<br/><br/>(Required) recurring\_window - Time window for recurring maintenance operations.<br/>(Required) recurring\_window.end\_time - Time for the (initial) recurring maintenance to end in RFC3339 format. This value is also used to calculate duration of the maintenance window.<br/>(Required) recurring\_window.start\_time - Time for the (initial) recurring maintenance to start in RFC3339 format.<br/>(Optional) recurring\_window.recurrence - RRULE recurrence rule for the recurring maintenance window specified in RFC5545 format. This value is used to compute the start time of subsequent windows.<br/><br/>(Optional) exclusions - Exceptions to maintenance window. Non-emergency maintenance should not occur in these windows. A cluster can have up to three maintenance exclusions at a time.<br/>(Required) exclusions.end\_time - Time for the maintenance exclusion to end in RFC3339 format.<br/>(Required) exclusions.name - Human-readable description of the maintenance exclusion. This field is for display purposes only.<br/>(Required) exclusions.start\_time - Time for the maintenance exclusion to start in RFC3339 format.<br/>(Optional) exclusions.scope - The scope of the maintenance exclusion. Possible values are `NO_UPGRADES`, `NO_MINOR_UPGRADES`, and `NO_MINOR_OR_NODE_UPGRADES`. | <pre>object({<br/>    recurring_window = object({<br/>      end_time   = string<br/>      recurrence = optional(string, "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH")<br/>      start_time = string<br/>    })<br/>    exclusions = optional(list(object({<br/>      end_time   = string<br/>      name       = string<br/>      scope      = optional(string)<br/>      start_time = string<br/>    })))<br/>  })</pre> | `null` | no |
| <a name="input_master_authorized_networks"></a> [master\_authorized\_networks](#input\_master\_authorized\_networks) | List of CIDR blocks permitted to reach the cluster master API endpoint. When<br/>null, access is unrestricted beyond the `enable_gcp_public_access` flag. For<br/>private clusters this should always be set to known egress CIDRs such as office,<br/>VPN, or CI/CD runner IP ranges.<br/><br/>(Required) cidr\_block - The CIDR range to allow.<br/>(Optional) display\_name - A human-readable label shown in the GCP Console. | <pre>list(object({<br/>    cidr_block   = string<br/>    display_name = optional(string)<br/>  }))</pre> | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the cluster. Used as a prefix for the generated cluster name unless `override_name` is set. | `string` | `null` | no |
| <a name="input_override_name"></a> [override\_name](#input\_override\_name) | Fully qualified, authoritative name of the cluster. When set, `name` is ignored and this value is used directly as the cluster name with no suffix appended. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | An optional prefix prepended to `name` when generating the cluster name. Has no effect when `override_name` is set. Cannot be an empty string — use null to omit. | `string` | `null` | no |
| <a name="input_private_cluster"></a> [private\_cluster](#input\_private\_cluster) | Private cluster configuration. When set, nodes receive only internal IP<br/>addresses. Recommended for all production clusters. When null, the cluster is<br/>not configured as private.<br/><br/>(Optional) enable\_private\_nodes - Assign only internal IPs to nodes. Defaults to true.<br/>(Optional) enable\_private\_endpoint - Expose the master via its internal IP only, removing all public access to the API endpoint. Defaults to false.<br/>(Optional) master\_ipv4\_cidr\_block - A `/28` CIDR for the hosted master network. Must not overlap with any other range in the VPC. Required when `enable_private_nodes` is true.<br/>(Optional) master\_exposed\_webhook\_ports - TCP port ranges the GKE control plane is permitted to reach on nodes, used for admission webhook traffic. Each entry may be a single port ("8443") or a range ("1024-65535"). Defaults to ["1024-65535"], which covers all webhook controllers without requiring per-component configuration. Restrict this if your security posture requires explicit port allowlisting. | <pre>object({<br/>    enable_private_nodes         = optional(bool, true)<br/>    enable_private_endpoint      = optional(bool, false)<br/>    master_ipv4_cidr_block       = optional(string)<br/>    master_exposed_webhook_ports = optional(list(string), ["1024-65535"])<br/>  })</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project in which to create the cluster. Defaults to the provider project if not set. | `string` | `null` | no |
| <a name="input_security_group"></a> [security\_group](#input\_security\_group) | Google Groups security group name for Kubernetes RBAC integration. Must be in the format `gke-security-groups@yourdomain.com`. | `string` | `null` | no |
| <a name="input_workload_identity_project_id"></a> [workload\_identity\_project\_id](#input\_workload\_identity\_project\_id) | The ID of the GCP project that hosts the Workload Identity pool. When set,<br/>configures the cluster to trust Kubernetes service account tokens issued against<br/>this pool, enabling Pods to authenticate to GCP APIs without long-lived<br/>credentials.<br/><br/>This is commonly a separate, dedicated project from the one the cluster runs<br/>in — for example, a centralised identity project shared across multiple clusters<br/>or environments.<br/><br/>The workload pool is derived as `PROJECT_ID.svc.id.goog`. When null, Workload<br/>Identity Federation is not configured on the cluster and Pods must use another<br/>authentication mechanism. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | Base64-encoded public certificate of the cluster's certificate authority. Used alongside the endpoint to authenticate a Kubernetes provider. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | IP address of the cluster master API endpoint. Use this to configure a Kubernetes or Helm provider. |
| <a name="output_id"></a> [id](#output\_id) | Fully qualified cluster ID in the format projects/PROJECT/locations/LOCATION/clusters/NAME. Use this as a stable reference when the cluster name alone is ambiguous. |
| <a name="output_name"></a> [name](#output\_name) | The name of the cluster as known to the GKE API. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | The URI of the cluster. Use this as a stable reference for IAM bindings or when referencing the cluster resource in other GCP configurations. |
| <a name="output_workload_identity_pool"></a> [workload\_identity\_pool](#output\_workload\_identity\_pool) | The Workload Identity pool for this cluster, in the format PROJECT.svc.id.goog. Use this when constructing the IAM member string for Workload Identity bindings: serviceAccount:POOL[K8S\_NAMESPACE/KSA\_NAME]. |
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
