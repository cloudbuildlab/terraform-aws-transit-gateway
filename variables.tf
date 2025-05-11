variable "name" {
  description = "Name for the Transit Gateway and related resources. This will be used as a prefix for all resource names."
  type        = string
  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 64
    error_message = "Name must be between 1 and 64 characters long."
  }
}

variable "description" {
  description = "Transit Gateway description. This helps identify the purpose of the Transit Gateway."
  type        = string
  default     = ""
  validation {
    condition     = length(var.description) <= 256
    error_message = "Description must be less than or equal to 256 characters."
  }
}

variable "amazon_side_asn" {
  description = "Private ASN for the Amazon side of the Transit Gateway. Must be in the range 64512-65534 for 16-bit ASNs or 4200000000-4294967294 for 32-bit ASNs."
  type        = number
  default     = 64512
  validation {
    condition     = (var.amazon_side_asn >= 64512 && var.amazon_side_asn <= 65534) || (var.amazon_side_asn >= 4200000000 && var.amazon_side_asn <= 4294967294)
    error_message = "ASN must be in the range 64512-65534 for 16-bit ASNs or 4200000000-4294967294 for 32-bit ASNs."
  }
}

variable "enable_dns_support" {
  description = "Enable DNS support for the Transit Gateway. When enabled, the Transit Gateway will resolve DNS hostnames for instances in the attached VPCs."
  type        = bool
  default     = true
}

variable "enable_security_group_referencing_support" {
  description = "Enable security group referencing support in Transit Gateway"
  type        = bool
  default     = false
}

variable "enable_vpn_ecmp_support" {
  description = "Enable VPN ECMP support in Transit Gateway"
  type        = bool
  default     = false
}

variable "associate_default_route_table" {
  description = "Associate attachments with the default Transit Gateway route table. When enabled, new attachments will automatically be associated with the default route table."
  type        = bool
  default     = true
}

variable "propagate_to_default_route_table" {
  description = "Propagate routes to the default Transit Gateway route table. When enabled, routes from attachments will automatically be propagated to the default route table."
  type        = bool
  default     = true
}

variable "auto_accept_attachments" {
  description = "Auto-accept VPC attachments from other AWS accounts. When enabled, attachments from other AWS accounts will be automatically accepted."
  type        = bool
  default     = true
}

variable "create_route_table" {
  description = "Whether to create a separate Transit Gateway route table. When enabled, a custom route table will be created instead of using the default route table."
  type        = bool
  default     = true
}

variable "vpc_attachments" {
  description = <<-EOT
Map of VPC attachments to be connected via Transit Gateway. Each map key represents a logical name.

Allowed attributes per VPC:
- enabled (bool, required)
- vpc_id (string, required, must start with "vpc-")
- subnet_ids (list of strings, required, each must start with "subnet-")
- ipv6_support (bool, optional)
- security_group_referencing_support (bool, optional)
- associate_with_route_table (bool, optional)
- propagate_to_route_table (bool, optional)
- tgw_routes (optional list of objects with `cidr` and optional `blackhole`)
- tags (map of strings, optional)

tgw_routes must use this structure:
tgw_routes = [
  { cidr = "10.0.0.0/16" },
  { cidr = "10.1.0.0/16", blackhole = true }
]
EOT

  type = map(object({
    enabled    = bool
    vpc_id     = string
    subnet_ids = list(string)

    ipv6_support                       = optional(bool, false)
    security_group_referencing_support = optional(bool, false)
    associate_with_route_table         = optional(bool, false)
    propagate_to_route_table           = optional(bool, false)

    tgw_routes = optional(list(object({
      cidr      = string
      blackhole = optional(bool, false)
    })), [])

    tags = optional(map(string), {})
  }))

  default = {}

  # Ensure vpc_id is valid
  validation {
    condition = alltrue([
      for v in values(var.vpc_attachments) :
      can(regex("^vpc-[0-9a-f]+$", v.vpc_id))
    ])
    error_message = "Each vpc_id must be a valid AWS VPC ID (starting with 'vpc-')."
  }

  # Ensure subnet_ids are valid
  validation {
    condition = alltrue(flatten([
      for v in values(var.vpc_attachments) :
      try([
        for sid in v.subnet_ids :
        can(regex("^subnet-[0-9a-f]+$", sid))
      ], [])
    ]))
    error_message = "Each subnet_id must be a valid AWS Subnet ID (starting with 'subnet-')."
  }

  # Ensure each tgw_route has valid CIDR
  validation {
    condition = alltrue(flatten([
      for v in values(var.vpc_attachments) :
      try([
        for r in v.tgw_routes :
        can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", r.cidr))
      ], [])
    ]))
    error_message = "Each tgw_route must contain a valid IPv4 CIDR (e.g., 10.0.0.0/16)."
  }

  # Validate keys: allow only the defined schema fields
  validation {
    condition = alltrue([
      for v in values(var.vpc_attachments) :
      alltrue([
        for k in keys(v) : contains([
          "enabled",
          "vpc_id",
          "subnet_ids",
          "ipv6_support",
          "security_group_referencing_support",
          "associate_with_route_table",
          "propagate_to_route_table",
          "tgw_routes",
          "tags"
        ], k)
      ])
    ])
    error_message = "Each vpc_attachments entry contains an unsupported attribute. Only the defined schema keys are allowed."
  }
}

variable "tags" {
  description = "Common tags for all Transit Gateway resources. These tags will be merged with the Name tag for each resource."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k, v in var.tags : length(k) > 0 && length(v) > 0])
    error_message = "Tag keys and values must not be empty."
  }
}
