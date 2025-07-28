# firewall\_rules

Terraform module to create and manage VPC firewall rules.

## Usage

See the [examples](../../examples) directory for working examples for reference:

```hcl
module "firewall_rules" {
  source  = "git::https://github.com/kapetndev/terraform-google-compute.git//modules/firewall_rules?ref=v0.1.0"
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

## Requirements

| Name | Version |
|------|---------|
| [terraform](https://www.terraform.io/) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| [google](https://registry.terraform.io/providers/hashicorp/google/latest) | >= 4.67.0 |

## Resources

| Name | Type |
|------|------|
| [`google_compute_firewall.rules[*]`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [`google_compute_firewall.allow_http`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [`google_compute_firewall.allow_https`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [`google_compute_firewall.allow_ssh`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `network` | The name of `self_link` of the the network to attach the firewall rules to | `string` | | yes |
| `default_rules` Default firewall rules to be applied to the VPC network | `object{...}` | `{}` | no |
| `default_rules.http_ranges` | A list of source CIDR ranges that are allowed to make HTTP requests to instances with matching tags. An empty list will disable the rule | `set(string)` | `[]` | no |
| `default_rules.http_tags` | A list of instance tags which are allowed to receive HTTP requests from sources with matching ranges | `set(string)` | `["http-server"]` | no |
| `default_rules.https_ranges` | A list of source CIDR ranges that are allowed to make HTTPS requests to instances with matching tags. An empty list will disable the rule | `set(string)` | `[]` | no |
| `default_rules.https_tags` | A list of instance tags which are allowed to receive HTTPS requests from sources with matching ranges | `set(string)` | `[]` | no |
| `default_rules.ssh_ranges` | A list of source CIDR ranges that are allowed to make SSH requests to instances with matching tags. An empty list will disable the rule | `set(string)` | `[]` | no |
| `default_rules.ssh_tags` | A list of instance tags which are allowed to receive SSH requests from sources with matching ranges | `set(string)` | `[]` | no |
| `egress_rules` | A list of firewall rules specified by the user to be applied to the VPC network | `list(object)` | `[]` | no |
| `egress_rules[*].protocol` | The IP protocol to which this rule applies. This value can either be one of the following well known protocol strings (`tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`), or the IP protocol number | `string` | | yes |
| `egress_rules[*].allow` | The firewall rule action. Either `allow` or `deny` | `string` | | yes |
| `egress_rules[*].description` | A description og the firewall rule | `string` | `null` | no |
| `egress_rules[*].destination_ranges` | If destination ranges are specified, the firewall will apply only to traffic that has destination IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported | `set(string)` | `null` | no |
| `egress_rules[*].log_config_include_metadata` | Denotes whether to include or exclude metadata for firewall logs. Possible values are: `EXCLUDE_ALL_METADATA`, `INCLUDE_ALL_METADATA`. Defaults to `INCLUDE_ALL_METADATA` | `string` | `INCLUDE_ALL_METADATA` | no |
| `egress_rules[*].ports` | An optional list of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. Each entry must be either an integer or a range. If not specified, this rule applies to connections through any port | `set(string)` | `null` | no |
| `egress_rules[*].priority` | A value between `0` and `65535` that specifies the priority of the rule. Defaults to `1000`. Relative priorities determine precedence of conflicting rules. Lower value of priority implies higher precedence. DENY rules take precedence over ALLOW rules having equal priority | `number` | `1000` | no |
| `egress_rules[*].source_ranges` | If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported | `set(string)` | `null` | no |
| `egress_rules[*].source_tags` | If source tags are specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags. Source tags cannot be used to control traffic to an instance's external IP address | `set(string)` | `null` | no |
| `egress_rules[*].target_tags` | A list of instance tags indicating sets of instances located in the network that may make network connections. If no target tags are specified, the firewall rule applies to all instances on the specified network | `set(string)` | `null` | no |
| `ingress_rules` | A list of firewall rules specified by the user to be applied to the VPC network | `list(object)` | `[]` | no |
| `ingress_rules[*].protocol` | The IP protocol to which this rule applies. This value can either be one of the following well known protocol strings (`tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`), or the IP protocol number | `string` | | yes |
| `ingress_rules[*].allow` | The firewall rule action. Either `allow` or `deny` | `string` | | yes |
| `ingress_rules[*].description` | A description og the firewall rule | `string` | `null` | no |
| `ingress_rules[*].destination_ranges` | If destination ranges are specified, the firewall will apply only to traffic that has destination IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported | `set(string)` | `null` | no |
| `ingress_rules[*].log_config_include_metadata` | Denotes whether to include or exclude metadata for firewall logs. Possible values are: `EXCLUDE_ALL_METADATA`, `INCLUDE_ALL_METADATA`. Defaults to `INCLUDE_ALL_METADATA` | `string` | `INCLUDE_ALL_METADATA` | no |
| `ingress_rules[*].ports` | An optional list of ports to which this rule applies. This field is only applicable for UDP or TCP protocol. Each entry must be either an integer or a range. If not specified, this rule applies to connections through any port | `set(string)` | `null` | no |
| `ingress_rules[*].priority` | A value between `0` and `65535` that specifies the priority of the rule. Defaults to `1000`. Relative priorities determine precedence of conflicting rules. Lower value of priority implies higher precedence. DENY rules take precedence over ALLOW rules having equal priority | `number` | `1000` | no |
| `ingress_rules[*].source_ranges` | If source ranges are specified, the firewall will apply only to traffic that has source IP address in these ranges. These ranges must be expressed in CIDR format. IPv4 or IPv6 ranges are supported | `set(string)` | `null` | no |
| `ingress_rules[*].source_tags` | If source tags are specified, the firewall will apply only to traffic with source IP that belongs to a tag listed in source tags. Source tags cannot be used to control traffic to an instance's external IP address | `set(string)` | `null` | no |
| `ingress_rules[*].target_tags` | A list of instance tags indicating sets of instances located in the network that may make network connections. If no target tags are specified, the firewall rule applies to all instances on the specified network | `set(string)` | `null` | no |
| `project_id` | The ID of the project in which the resource belongs. If it is not provided, the provider project is used | `string` | `null` | no |
