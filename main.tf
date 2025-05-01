# ===================================
# Locals
# ===================================

locals {
  # Route table associations and propagations
  route_table_associations = {
    for k, v in var.vpc_attachments :
    k => v
    if try(v.enabled, true) && try(v.associate_with_route_table, false)
  }

  route_table_propagations = {
    for k, v in var.vpc_attachments :
    k => v
    if try(v.enabled, true) && try(v.propagate_to_route_table, false)
  }

  # Route processing
  raw_tgw_routes = flatten([
    for vpc_key, vpc in var.vpc_attachments :
    try(vpc.enabled, true) ? [
      for r in try(vpc.tgw_routes, []) : {
        key           = "${vpc_key}-${r.cidr}"
        cidr          = r.cidr
        blackhole     = try(r.blackhole, false)
        attachment_id = aws_ec2_transit_gateway_vpc_attachment.this[vpc_key].id
      }
    ] : []
  ])

  tgw_routes = var.create_route_table ? {
    for entry in local.raw_tgw_routes : entry.key => {
      cidr          = entry.cidr
      blackhole     = entry.blackhole
      attachment_id = entry.attachment_id
    }
  } : {}
}

# ===================================
# Transit Gateway
# ===================================

resource "aws_ec2_transit_gateway" "this" {
  description                        = var.description
  amazon_side_asn                    = var.amazon_side_asn
  default_route_table_association    = var.associate_default_route_table ? "enable" : "disable"
  default_route_table_propagation    = var.propagate_to_default_route_table ? "enable" : "disable"
  auto_accept_shared_attachments     = var.auto_accept_attachments ? "enable" : "disable"
  dns_support                        = var.enable_dns_support ? "enable" : "disable"
  security_group_referencing_support = var.enable_security_group_referencing_support ? "enable" : "disable"
  vpn_ecmp_support                   = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(var.tags, {
    Name = var.name
  })
}

# ===================================
# Transit Gateway Route Table
# ===================================

resource "aws_ec2_transit_gateway_route_table" "this" {
  count = var.create_route_table ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(var.tags, {
    Name = "${var.name}-rt"
  })
}

# ===================================
# Transit Gateway Attachments
# ===================================

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  for_each = { for k, v in var.vpc_attachments : k => v if v.enabled }

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  vpc_id             = each.value.vpc_id

  ipv6_support                                    = try(each.value.ipv6_support, false) ? "enable" : "disable"
  security_group_referencing_support              = try(each.value.security_group_referencing_support, false) ? "enable" : "disable"
  transit_gateway_default_route_table_association = var.create_route_table ? false : try(each.value.associate_with_route_table, true)
  transit_gateway_default_route_table_propagation = var.create_route_table ? false : try(each.value.propagate_to_route_table, true)

  tags = merge(var.tags, {
    Name = "${var.name}-${each.key}-attachment"
  }, lookup(each.value, "tags", {}))
}

# ===================================
# Route Table Associations
# ===================================

resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.create_route_table ? local.route_table_associations : {}

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[0].id
}

# ===================================
# Route Table Propagations
# ===================================

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = var.create_route_table ? local.route_table_propagations : {}

  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this[each.key].id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[0].id
}

# ===================================
# Transit Gateway Routes
# ===================================

resource "aws_ec2_transit_gateway_route" "this" {
  for_each = var.create_route_table ? local.tgw_routes : {}

  destination_cidr_block         = each.value.cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this[0].id
  transit_gateway_attachment_id  = each.value.blackhole ? null : each.value.attachment_id
  blackhole                      = each.value.blackhole
}
