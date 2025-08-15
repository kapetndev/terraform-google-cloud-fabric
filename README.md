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

<!-- pyml disable-num-lines 7 md013 -->
| Name | Category | Location | Description |
|------|----------|----------|-------------|
| [service_account](modules/iam/service_account) | iam | `modules/iam/service_account` | A module to create and manage GCP service accounts. |
| [workload_identity_pool](modules/iam/workload_identity_pool) | iam | `modules/iam/workload_identity_pool` | A module to create and manage GCP Workload Identity Pools and associated providers. |
| [folder](modules/platform/folder) | platform | `modules/platform/folder` | A module to create and manage GCP organizational folders. |
| [organization](modules/platform/organization) | platform | `modules/platform/organization` | A module to manage GCP organization policies. |
| [project](modules/platform/project) | platform | `modules/platform/project` | A module to create and manage GCP projects. |

## License

This project is licensed under the [MIT License](LICENSE).
