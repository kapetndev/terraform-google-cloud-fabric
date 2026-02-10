# Firewall Rules

Terraform module to create and manage VPC firewall rules that control ingress
and egress traffic. Rules support both allow and deny actions, operating with
priority-based precedence and tag-based targeting.

## Usage

```hcl
module "firewall_rules" {
  source  = "github.com/kapetndev/terraform-google-cloud-fabric//modules/compute/firewall_rules?ref=v0.1.0"
  network = data.google_compute_network.my_vpc.name

  egress_rules = {
    "deny-smtp" = {
      allow    = false
      protocol = "tcp"
      ports    = ["25"]
    }
  }

  ingress_rules = {
    "allow-ftp" = {
      allow       = true
      protocol    = "tcp"
      ports       = ["21"]
      target_tags = ["ftp-server"]
    }
    "deny-rdp" = {
      allow        = false
      protocol     = "tcp"
      ports        = ["3389"]
      source_ranges = ["0.0.0.0/0"]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
<!-- pyml disable md013,md022,md033 -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.60.0 |

## Resources

| Name | Type |
|------|------|
| [google_compute_firewall.rules](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_network"></a> [network](#input\_network) | Name or `self_link` of the VPC network to attach the firewall rules to. | `string` | n/a | yes |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | Egress firewall rules to apply to the VPC network, keyed by a short descriptive<br/>name. Each key is prefixed with the network name when creating the GCP resource,<br/>so keys should be brief descriptors rather than full rule names<br/>(e.g. "deny-internal" rather than "my-vpc-deny-internal").<br/><br/>(Required) allow - Whether to allow (true) or deny (false) matching traffic.<br/>(Required) protocol - IP protocol. One of `tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`, or an IP protocol number.<br/><br/>(Optional) description - Human-readable description of the rule.<br/>(Optional) priority - Rule priority between 0 and 65535. Lower values take precedence. Defaults to 1000. DENY rules take precedence over ALLOW rules at equal priority.<br/>(Optional) ports - TCP/UDP ports or ranges the rule applies to, e.g. ["443", "8080-8090"]. Omit to match all ports.<br/>(Optional) destination\_ranges - Destination CIDR ranges the rule applies to.  When null, defaults to `0.0.0.0/0`.<br/>(Optional) target\_tags - Network tags identifying the source instances the rule applies to. When null the rule applies to all instances in the network.<br/>(Optional) log\_config\_include\_metadata - When set, enables firewall rule logging. true includes all metadata; false excludes it. | <pre>map(object({<br/>    allow                       = bool<br/>    description                 = optional(string)<br/>    destination_ranges          = optional(set(string))<br/>    log_config_include_metadata = optional(bool)<br/>    ports                       = optional(set(string))<br/>    priority                    = optional(number, 1000)<br/>    protocol                    = string<br/>    target_tags                 = optional(set(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | Ingress firewall rules to apply to the VPC network, keyed by a short descriptive<br/>name. Each key is prefixed with the network name when creating the GCP resource,<br/>so keys should be brief descriptors rather than full rule names<br/>(e.g. "allow-ssh" rather than "my-vpc-allow-ssh").<br/><br/>(Required) allow - Whether to allow (true) or deny (false) matching traffic.<br/>(Required) protocol - IP protocol. One of `tcp`, `udp`, `icmp`, `esp`, `ah`, `sctp`, `ipip`, `all`, or an IP protocol number.<br/><br/>(Optional) description - Human-readable description of the rule.<br/>(Optional) priority - Rule priority between 0 and 65535. Lower values take precedence. Defaults to 1000. DENY rules take precedence over ALLOW rules at equal priority.<br/>(Optional) ports - TCP/UDP ports or ranges the rule applies to, e.g.  ["80", "8080-8090"]. Omit to match all ports.<br/>(Optional) source\_ranges - Source CIDR ranges the rule applies to. When null and source\_tags is also null, defaults to `0.0.0.0/0`.<br/>(Optional) source\_tags - Source network tags the rule applies to. Cannot be used to control traffic to an instance's external IP address.<br/>(Optional) target\_tags - Network tags identifying the target instances. When null the rule applies to all instances in the network.<br/>(Optional) log\_config\_include\_metadata - When set, enables firewall rule logging. true includes all metadata; false excludes it. | <pre>map(object({<br/>    allow                       = bool<br/>    description                 = optional(string)<br/>    log_config_include_metadata = optional(bool)<br/>    ports                       = optional(set(string))<br/>    priority                    = optional(number, 1000)<br/>    protocol                    = string<br/>    source_ranges               = optional(set(string))<br/>    source_tags                 = optional(set(string))<br/>    target_tags                 = optional(set(string))<br/>  }))</pre> | `{}` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the GCP project in which to create the firewall rules. Defaults to the provider project if not set. | `string` | `null` | no |

## Outputs

No outputs.
<!-- pyml enable md013,md022,md033 -->
<!-- END_TF_DOCS -->
