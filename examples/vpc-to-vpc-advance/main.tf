############################################
# Terraform & Provider Configuration
############################################

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

############################################
# Variables
############################################

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-1"
}

variable "environment" {
  description = "Environment name prefix"
  type        = string
  default     = "dev"
}

############################################
# Locals - Centralized Settings
############################################

locals {
  vpc1_cidr    = "10.1.0.0/16"
  vpc2_cidr    = "10.2.0.0/16"
  default_cidr = "0.0.0.0/0"

  vpc1_private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  vpc2_private_subnets = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

############################################
# VPC Modules
############################################

module "vpc1" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.0"

  vpc_name = "${var.environment}-vpc1"
  vpc_cidr = local.vpc1_cidr

  availability_zones   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnet_cidrs = local.vpc1_private_subnets

  enable_nacls        = false
  enable_nat_gateway  = false
  create_igw          = false
  enable_route_tables = true

  # ⚠️ NOTE:
  # When using `custom_routes` with `transit_gateway_id`, the route table must:
  # - Be associated with a subnet (required for the route to be valid),
  # - Reference a Transit Gateway that is created in the same region,
  # - AND the Transit Gateway **must be attached to this VPC** via `vpc_attachments`
  #   in the `transit_gateway` module — otherwise routing will fail with
  #   `InvalidTransitGatewayID.NotFound` or be unselectable in the console.
  custom_routes = {
    private = {
      use_only = true
      routes = [
        {
          cidr_block         = local.vpc2_cidr
          transit_gateway_id = module.transit_gateway.transit_gateway_id
        }
      ]
    }
  }

  tags = merge(local.tags, {
    Name = "${var.environment}-vpc1"
  })
}

module "vpc2" {
  source  = "cloudbuildlab/vpc/aws"
  version = ">= 1.0.0"

  vpc_name = "${var.environment}-vpc2"
  vpc_cidr = local.vpc2_cidr

  availability_zones   = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnet_cidrs = local.vpc2_private_subnets

  enable_nacls        = false
  enable_nat_gateway  = false
  create_igw          = false
  enable_route_tables = true

  # ⚠️ NOTE:
  # When using `custom_routes` with `transit_gateway_id`, the route table must:
  # - Be associated with a subnet (required for the route to be valid),
  # - Reference a Transit Gateway that is created in the same region,
  # - AND the Transit Gateway **must be attached to this VPC** via `vpc_attachments`
  #   in the `transit_gateway` module — otherwise routing will fail with
  #   `InvalidTransitGatewayID.NotFound` or be unselectable in the console.
  custom_routes = {
    private = {
      use_only = true
      routes = [
        {
          cidr_block         = local.vpc1_cidr
          transit_gateway_id = module.transit_gateway.transit_gateway_id
        }
      ]
    }
  }

  tags = merge(local.tags, {
    Name = "${var.environment}-vpc2"
  })
}

############################################
# Transit Gateway Module
############################################

module "transit_gateway" {
  source = "../../"

  name        = "${var.environment}-transit-gateway"
  description = "Transit Gateway to connect VPCs"

  amazon_side_asn                  = 64512
  enable_dns_support               = true
  associate_default_route_table    = false
  propagate_to_default_route_table = false
  auto_accept_attachments          = false
  create_route_table               = true

  vpc_attachments = {
    vpc1 = {
      enabled                    = true
      vpc_id                     = module.vpc1.vpc_id
      subnet_ids                 = module.vpc1.private_subnet_ids
      tags                       = local.tags
      associate_with_route_table = true
      propagate_to_route_table   = true
      tgw_routes = [
        { cidr = local.vpc1_cidr }
      ]
    }
    vpc2 = {
      enabled                    = true
      vpc_id                     = module.vpc2.vpc_id
      subnet_ids                 = module.vpc2.private_subnet_ids
      tags                       = local.tags
      associate_with_route_table = true
      propagate_to_route_table   = true
      tgw_routes = [
        { cidr = local.vpc2_cidr }
      ]
    }
  }

  tags = merge(local.tags, {
    Purpose = "VPC connectivity"
  })
}

############################################
# EC2 Testing Module Calls
############################################

module "test_vpc1" {
  source = "../../modules/test-instance"

  name_prefix = "${var.environment}-vpc1"
  subnet_ids  = module.vpc1.private_subnet_ids
  vpc_id      = module.vpc1.vpc_id
  tags        = local.tags
}

module "test_vpc2" {
  source = "../../modules/test-instance"

  name_prefix = "${var.environment}-vpc2"
  subnet_ids  = module.vpc2.private_subnet_ids
  vpc_id      = module.vpc2.vpc_id
  tags        = local.tags
}

output "test_vpc1" {
  value = module.test_vpc1
}

output "test_vpc2" {
  value = module.test_vpc2
}

output "transit_gateway" {
  value = module.transit_gateway
}
