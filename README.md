# terraform-google-cloud-fabric ![terraform](https://github.com/kapetndev/terraform-google-cloud-fabric/workflows/terraform/badge.svg)

This repository provides a collection of Terraform modules and complete
architectural solutions to create and manage Google Cloud Platform (GCP)
resources suitable for a variety of use cases.

The purpose of this repository is to provide a foundation for building cloud
infrastructure that is secure, scalable, and maintainable.

## Modules

Modules provide the reusable components for building GCP resources. Each module
is designed to be used independently or as part of a larger architecture. The
modules are organized by category, such as compute, database, storage, and
security. Below is a list of available modules with their respective categories
and locations within the repository.

<!-- pyml disable-num-lines 15 md013 -->
| Name | Category | Location | Description |
|------|----------|----------|-------------|
| [firewall_rules](modules/compute/firewall_rules) | compute | `modules/compute/firewall_rules` | A module to create firewall rules for GCP compute resources. |
| [gce_instance](modules/compute/gce_instance) | compute | `modules/compute/gce_instance` | A module to create and manage GCP Compute Engine instances. |
| [gke_cluster](modules/compute/gke_cluster) | compute | `modules/compute/gke_cluster` | A module to create and manage GCP Kubernetes Engine clusters. |
| [gke_node_pool](modules/compute/gke_node_pool) | compute | `modules/compute/gke_node_pool` | A module to create and manage GCP Kubernetes Engine node pools. |
| [vpc_network](modules/compute/vpc_network) | compute | `modules/compute/vpc_network` | A module to create and manage GCP VPC networks. |
| [cloudsql_instance](modules/database/cloudsql_instance) | database | `modules/database/cloudsql_instance` | A module to create and manage GCP Cloud SQL instances. |
| [redis_instance](modules/database/redis_instance) | database | `modules/database/redis_instance` | A module to create and manage GCP Redis instances. |
| [service_account](modules/iam/service_account) | iam | `modules/iam/service_account` | A module to create and manage GCP service accounts. |
| [workload_identity_pool](modules/iam/workload_identity_pool) | iam | `modules/iam/workload_identity_pool` | A module to create and manage GCP Workload Identity Pools and associated providers. |
| [folder](modules/platform/folder) | platform | `modules/platform/folder` | A module to create and manage GCP organizational folders. |
| [organization](modules/platform/organization) | platform | `modules/platform/organization` | A module to manage GCP organization policies. |
| [project](modules/platform/project) | platform | `modules/platform/project` | A module to create and manage GCP projects. |
| [gcs_bucket](modules/storage/gcs_bucket) | storage | `modules/storage/gcs_bucket` | A module to create and manage GCP Cloud Storage buckets. |

## License

This project is licensed under the [MIT License](LICENSE).
