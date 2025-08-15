# Firewall Rules

Terraform module to create and manage VPC firewall rules.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "firewall_rules" {
  source  = "git::https://github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/firewall_rules?ref=v0.1.0"
  network = data.google_compute_newtork.my_vpc.name

  # Allow HTTP, HTTPS, and SSH from anywhere.
  default_rules = {
    http_ranges  = ["0.0.0.0/0"]
    https_ranges = ["0.0.0.0/0"]
    ssh_ranges   = ["0.0.0.0/0"]
  }

  egress_rules = {
    "my-vpc-deny-smtp" = {
      ports         = ["25"]
      source_ranges = ["10.170.0.0/20"]
    }
  }

  ingress_rules = {
    "my-vpc-allow-ftp" = {
      allow       = true
      ports       = ["21"]
      target_tags = ["ftp-server"]
    }
    "my-vpc-deny-remote-desktop" = {
      ports              = ["3389"]
      destination_ranges = ["0.0.0.0/0"]
    }
  }
}
```

## Examples

- [network-and-rules](../../examples/network-and-rules) - Create a VPC with
  additional configuration to manage subnetworks and firewall rules.

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.33.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.33.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.allow_http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.allow_ssh](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_firewall.rules](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network"></a> [network](#input\_network) | The name of `self_link` of the the network to attach the firewall rules to. | `string` | n/a | yes |
| <a name="input_default_rules"></a> [default\_rules](#input\_default\_rules) | Default firewall rules to be applied to the VPC network.<br/><br/>(Optional) http\_ranges - A list of source CIDR ranges that are allowed to make HTTP requests to instances with matching tags. An empty list will disable the rule.<br/>(Optional) http\_tags - A list of instance tags which are allowed to receive HTTP requests from sources with matching ranges.<br/>(Optional) https\_ranges - A list of source CIDR ranges that are allowed to make HTTPS requests to instances with matching tags. An empty list will disable the rule.<br/>(Optional) https\_tags - A list of instance tags which are allowed to receive HTTPS requests from sources with matching ranges.<br/>(Optional) ssh\_ranges - A list of source CIDR ranges that are allowed to make SSH requests to instances with matching tags. An empty list will disable the rule.<br/>(Optional) ssh\_tags - A list of instance tags which are allowed to receive SSH requests from sources with matching ranges. | <pre>object({<br/>    http_ranges  = optional(set(string), [])<br/>    http_tags    = optional(set(string), ["http-server"])<br/>    https_ranges = optional(set(string), [])<br/>    https_tags   = optional(set(string), ["https-server"])<br/>    ssh_ranges   = optional(set(string), [])<br/>    ssh_tags     = optional(set(string), ["ssh-server"])<br/>  })</pre> | `{}` | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | A list of egress firewall rules specified by the user to be applied to the VPC network.<br/><br/>(Required) protocol - The IP protocol to which this rule applies. This value can either be one of the following well known protocol strings (`tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`), or the IP protocol number.<br/><br/>(Optional) allow - The firewall rule action. Setting this to `true` will allow all traffic matching the rule; otherwise this will deny all traffic. Default value is `false`.<br/>(Optional) description - A description og the firewall rule.<br/>(Optional) destination\_ranges - If destination ranges are specified, the firewall will apply only to traffic that has destination IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.<br/>(Optional) log\_config\_iinclude\_metadata - Whether to include or exclude metadata for firewall logs.<br/>(Optional) ports - An optional list of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. Each entry must be either an integer or a range. If not specified, this rule applies to connections through any port.<br/>(Optional) priority - A value between `0` and `65535` that specifies the priority of the rule. Defaults to `1000`. Relative priorities determine precedence of conflicting rules. Lower value of priority implies higher precedence. DENY rules take precedence over ALLOW rules having equal priority.<br/>(Optional) source\_ranges - If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.<br/>(Optional) source\_tags - If source tags are specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags. Source tags cannot be used to control traffic to an instance's external IP address.<br/>(Optional) target\_tags - A list of instance tags indicating sets of instances located in the network that may make network connections. If no target tags are specified, the firewall rule applies to all instances on the specified network. | <pre>map(object({<br/>    allow                       = optional(bool, false)<br/>    description                 = optional(string)<br/>    destination_ranges          = optional(set(string))<br/>    log_config_include_metadata = optional(bool)<br/>    ports                       = optional(set(string))<br/>    priority                    = optional(number, 1000)<br/>    protocol                    = string<br/>    source_ranges               = optional(set(string))<br/>    source_tags                 = optional(set(string))<br/>    target_tags                 = optional(set(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | A list of ingress firewall rules specified by the user to be applied to the VPC network.<br/><br/>(Required) protocol - The IP protocol to which this rule applies. This value can either be one of the following well known protocol strings (`tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`), or the IP protocol number.<br/><br/>(Optional) allow - The firewall rule action. Setting this to `true` will allow all traffic matching the rule; otherwise this will deny all traffic. Default value is `false`.<br/>(Optional) description - A description og the firewall rule.<br/>(Optional) destination\_ranges - If destination ranges are specified, the firewall will apply only to traffic that has destination IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.<br/>(Optional) log\_config\_iinclude\_metadata - Whether to include or exclude metadata for firewall logs.<br/>(Optional) ports - An optional list of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. Each entry must be either an integer or a range. If not specified, this rule applies to connections through any port.<br/>(Optional) priority - A value between `0` and `65535` that specifies the priority of the rule. Defaults to `1000`. Relative priorities determine precedence of conflicting rules. Lower value of priority implies higher precedence. DENY rules take precedence over ALLOW rules having equal priority.<br/>(Optional) source\_ranges - If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported.<br/>(Optional) source\_tags - If source tags are specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags. Source tags cannot be used to control traffic to an instance's external IP address.<br/>(Optional) target\_tags - A list of instance tags indicating sets of instances located in the network that may make network connections. If no target tags are specified, the firewall rule applies to all instances on the specified network. | <pre>map(object({<br/>    allow                       = optional(bool, false)<br/>    description                 = optional(string)<br/>    destination_ranges          = optional(set(string))<br/>    log_config_include_metadata = optional(bool)<br/>    ports                       = optional(set(string))<br/>    priority                    = optional(number, 1000)<br/>    protocol                    = string<br/>    source_ranges               = optional(set(string))<br/>    source_tags                 = optional(set(string))<br/>    target_tags                 = optional(set(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. If it is not provided, the provider project is used. | `string` | `null` | no |

## Outputs

No outputs.
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
