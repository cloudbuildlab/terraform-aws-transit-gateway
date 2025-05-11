# Run setup to create a VPC
run "setup_tgw" {
  module {
    source = "./tests/setup"
  }
}

run "test_tgw_configuration" {
  variables {
    name        = "test-tgw-${run.setup_tgw.suffix}"
    description = "Transit Gateway for testing"

    amazon_side_asn                  = 64512
    enable_dns_support               = true
    associate_default_route_table    = true
    propagate_to_default_route_table = true
    auto_accept_attachments          = false
    create_route_table               = false

    # vpc_attachments = {
    #   spoke1 = {
    #     enabled                    = true
    #     vpc_id                     = "vpc-12345678"
    #     subnet_ids                 = ["subnet-aaaa", "subnet-bbbb"]
    #     associate_with_route_table = true
    #     propagate_to_route_table   = true
    #     tgw_routes = [
    #       { cidr = "10.1.0.0/16" },
    #       { cidr = "10.2.0.0/16" }
    #     ]
    #   }

    #   spoke2 = {
    #     enabled                    = true
    #     vpc_id                     = "vpc-87654321"
    #     subnet_ids                 = ["subnet-cccc", "subnet-dddd"]
    #     associate_with_route_table = true
    #     propagate_to_route_table   = true
    #     tgw_routes = [
    #       { cidr = "10.0.0.0/16" }
    #     ]
    #   }
    # }

    tags = {
      Environment = "test"
    }
  }

  # Assertions

  assert {
    condition     = length(aws_ec2_transit_gateway.this) > 0
    error_message = "Transit Gateway was not created as expected."
  }
}
