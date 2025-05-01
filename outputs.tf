output "transit_gateway_id" {
  description = "The ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.id
}

output "transit_gateway_arn" {
  description = "The ARN of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.arn
}

output "transit_gateway_owner_id" {
  description = "The AWS account ID of the owner of the Transit Gateway"
  value       = aws_ec2_transit_gateway.this.owner_id
}

output "transit_gateway_route_table_id" {
  description = "The ID of the custom Transit Gateway route table (if created)"
  value       = try(aws_ec2_transit_gateway_route_table.this[0].id, null)
}

output "transit_gateway_route_table_arn" {
  description = "The ARN of the custom Transit Gateway route table (if created)"
  value       = try(aws_ec2_transit_gateway_route_table.this[0].arn, null)
}

output "vpc_attachment_ids" {
  description = "Map of VPC attachment IDs by logical name"
  value = {
    for key, att in aws_ec2_transit_gateway_vpc_attachment.this :
    key => att.id
  }
}

output "vpc_attachment_arns" {
  description = "Map of VPC attachment ARNs by logical name"
  value = {
    for key, att in aws_ec2_transit_gateway_vpc_attachment.this :
    key => att.arn
  }
}

output "route_table_association_ids" {
  description = "Map of route table association IDs by logical name"
  value = {
    for key, assoc in aws_ec2_transit_gateway_route_table_association.this :
    key => assoc.id
  }
}

output "route_table_propagation_ids" {
  description = "Map of route table propagation IDs by logical name"
  value = {
    for key, prop in aws_ec2_transit_gateway_route_table_propagation.this :
    key => prop.id
  }
}

output "transit_gateway_configuration" {
  description = "Map of Transit Gateway configuration attributes"
  value = {
    id                              = aws_ec2_transit_gateway.this.id
    arn                             = aws_ec2_transit_gateway.this.arn
    owner_id                        = aws_ec2_transit_gateway.this.owner_id
    amazon_side_asn                 = aws_ec2_transit_gateway.this.amazon_side_asn
    dns_support                     = aws_ec2_transit_gateway.this.dns_support
    default_route_table_association = aws_ec2_transit_gateway.this.default_route_table_association
    default_route_table_propagation = aws_ec2_transit_gateway.this.default_route_table_propagation
    auto_accept_shared_attachments  = aws_ec2_transit_gateway.this.auto_accept_shared_attachments
  }
}
