# terraform-aws-transit-gateway

Terraform module for provisioning AWS Transit Gateway and VPC attachments

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.96.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_transit_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway) | resource |
| [aws_ec2_transit_gateway_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route) | resource |
| [aws_ec2_transit_gateway_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table) | resource |
| [aws_ec2_transit_gateway_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_association) | resource |
| [aws_ec2_transit_gateway_route_table_propagation.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_route_table_propagation) | resource |
| [aws_ec2_transit_gateway_vpc_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_transit_gateway_vpc_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_side_asn"></a> [amazon\_side\_asn](#input\_amazon\_side\_asn) | Private ASN for the Amazon side of the Transit Gateway. Must be in the range 64512-65534 for 16-bit ASNs or 4200000000-4294967294 for 32-bit ASNs. | `number` | `64512` | no |
| <a name="input_associate_default_route_table"></a> [associate\_default\_route\_table](#input\_associate\_default\_route\_table) | Associate attachments with the default Transit Gateway route table. When enabled, new attachments will automatically be associated with the default route table. | `bool` | `true` | no |
| <a name="input_auto_accept_attachments"></a> [auto\_accept\_attachments](#input\_auto\_accept\_attachments) | Auto-accept VPC attachments from other AWS accounts. When enabled, attachments from other AWS accounts will be automatically accepted. | `bool` | `true` | no |
| <a name="input_create_route_table"></a> [create\_route\_table](#input\_create\_route\_table) | Whether to create a separate Transit Gateway route table. When enabled, a custom route table will be created instead of using the default route table. | `bool` | `true` | no |
| <a name="input_description"></a> [description](#input\_description) | Transit Gateway description. This helps identify the purpose of the Transit Gateway. | `string` | `""` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Enable DNS support for the Transit Gateway. When enabled, the Transit Gateway will resolve DNS hostnames for instances in the attached VPCs. | `bool` | `true` | no |
| <a name="input_enable_security_group_referencing_support"></a> [enable\_security\_group\_referencing\_support](#input\_enable\_security\_group\_referencing\_support) | Enable security group referencing support in Transit Gateway | `bool` | `false` | no |
| <a name="input_enable_vpn_ecmp_support"></a> [enable\_vpn\_ecmp\_support](#input\_enable\_vpn\_ecmp\_support) | Enable VPN ECMP support in Transit Gateway | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Transit Gateway and related resources. This will be used as a prefix for all resource names. | `string` | n/a | yes |
| <a name="input_propagate_to_default_route_table"></a> [propagate\_to\_default\_route\_table](#input\_propagate\_to\_default\_route\_table) | Propagate routes to the default Transit Gateway route table. When enabled, routes from attachments will automatically be propagated to the default route table. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Common tags for all Transit Gateway resources. These tags will be merged with the Name tag for each resource. | `map(string)` | `{}` | no |
| <a name="input_vpc_attachments"></a> [vpc\_attachments](#input\_vpc\_attachments) | Map of VPC attachments to be connected via Transit Gateway. Each map key represents a logical name.<br/><br/>Allowed attributes per VPC:<br/>- enabled (bool, required)<br/>- vpc\_id (string, required, must start with "vpc-")<br/>- subnet\_ids (list of strings, required, each must start with "subnet-")<br/>- ipv6\_support (bool, optional)<br/>- security\_group\_referencing\_support (bool, optional)<br/>- associate\_with\_route\_table (bool, optional)<br/>- propagate\_to\_route\_table (bool, optional)<br/>- tgw\_routes (optional list of objects with `cidr` and optional `blackhole`)<br/>- tags (map of strings, optional)<br/><br/>tgw\_routes must use this structure:<br/>tgw\_routes = [<br/>  { cidr = "10.0.0.0/16" },<br/>  { cidr = "10.1.0.0/16", blackhole = true }<br/>] | <pre>map(object({<br/>    enabled    = bool<br/>    vpc_id     = string<br/>    subnet_ids = list(string)<br/><br/>    ipv6_support                       = optional(bool, false)<br/>    security_group_referencing_support = optional(bool, false)<br/>    associate_with_route_table         = optional(bool, false)<br/>    propagate_to_route_table           = optional(bool, false)<br/><br/>    tgw_routes = optional(list(object({<br/>      cidr      = string<br/>      blackhole = optional(bool, false)<br/>    })), [])<br/><br/>    tags = optional(map(string), {})<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_route_table_association_ids"></a> [route\_table\_association\_ids](#output\_route\_table\_association\_ids) | Map of route table association IDs by logical name |
| <a name="output_route_table_propagation_ids"></a> [route\_table\_propagation\_ids](#output\_route\_table\_propagation\_ids) | Map of route table propagation IDs by logical name |
| <a name="output_transit_gateway_arn"></a> [transit\_gateway\_arn](#output\_transit\_gateway\_arn) | The ARN of the Transit Gateway |
| <a name="output_transit_gateway_configuration"></a> [transit\_gateway\_configuration](#output\_transit\_gateway\_configuration) | Map of Transit Gateway configuration attributes |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | The ID of the Transit Gateway |
| <a name="output_transit_gateway_owner_id"></a> [transit\_gateway\_owner\_id](#output\_transit\_gateway\_owner\_id) | The AWS account ID of the owner of the Transit Gateway |
| <a name="output_transit_gateway_route_table_arn"></a> [transit\_gateway\_route\_table\_arn](#output\_transit\_gateway\_route\_table\_arn) | The ARN of the custom Transit Gateway route table (if created) |
| <a name="output_transit_gateway_route_table_id"></a> [transit\_gateway\_route\_table\_id](#output\_transit\_gateway\_route\_table\_id) | The ID of the custom Transit Gateway route table (if created) |
| <a name="output_vpc_attachment_arns"></a> [vpc\_attachment\_arns](#output\_vpc\_attachment\_arns) | Map of VPC attachment ARNs by logical name |
| <a name="output_vpc_attachment_ids"></a> [vpc\_attachment\_ids](#output\_vpc\_attachment\_ids) | Map of VPC attachment IDs by logical name |
<!-- END_TF_DOCS -->
