# VPC-to-VPC Hub-and-Spoke (Private Routing via Transit Gateway)

This Terraform configuration demonstrates a **hub-and-spoke network topology** using **AWS Transit Gateway**. It enables **private routing** between three VPCs:

* `hub`: Central services VPC with internet access via NAT Gateway
* `vpc1` and `vpc2`: Spoke VPCs connected privately to the hub and each other via the Transit Gateway

> 🔒 **Note:** Only the **hub** VPC has internet access. Spoke VPCs (vpc1, vpc2) can only communicate privately via the Transit Gateway — **they cannot reach the internet**, by design.

---

## Module Structure

```plaintext
.
├── main.tf                   # Core Terraform configuration
├── modules/
│   └── test-instance/        # Reusable EC2 testing module
```

---

## 🔧 What This Does

* Creates three VPCs (`hub`, `vpc1`, and `vpc2`) in the same region
* Connects them using a shared **Transit Gateway**
* Creates a **custom TGW route table** with explicit propagation
* Enables route table entries for **hub-spoke and spoke-spoke** routing
* Launches **EC2 instances** in each VPC for connectivity tests

---

## Requirements

* Terraform >= 1.0.0
* AWS provider >= 4.0.0
* AWS credentials (via environment or `~/.aws/credentials`)

---

## Usage

```bash
terraform init
terraform apply
```

You can override the region or environment like this:

```bash
terraform apply -var="region=ap-southeast-1" -var="environment=dev"
```

---

## Outputs

After `apply`, you get:

* `test_hub`: Instance IDs and private IPs in the hub VPC
* `test_vpc1`: Instance IDs and private IPs in VPC1
* `test_vpc2`: Same for VPC2

---

## Modules Used

### `cloudbuildlab/vpc/aws`

Used to create minimal, configurable VPCs with route tables, subnets, IGWs, and optional NAT gateways.

### `modules/test-instance`

Reusable module to:

* Launch 1 EC2 instance per subnet
* Create an EC2 Instance Connect endpoint
* Assign security groups with SSH/ICMP open to your IP

---

## Test Connectivity

After apply:

```bash
# Connect to hub EC2 instance
aws ssm start-session --target <hub-instance-id>

# Ping VPC1 and VPC2
ping 10.1.1.x
ping 10.2.1.x

# Confirm internet access
curl http://example.com
```

```bash
# Connect to VPC1 EC2 instance
aws ssm start-session --target <vpc1-instance-id>

# Test internal only (will succeed)
ping 10.0.11.x     # hub
ping 10.2.1.x      # vpc2

# Test internet (will fail)
curl http://example.com
```

---

## 🚀 What Makes This "Advanced"?

* Transit Gateway uses a **custom route table** (`create_route_table = true`)
* All attachments use `associate_with_route_table` and `propagate_to_route_table`
* Spoke VPCs **do not have IGWs or NAT Gateways**
* The hub serves as the only egress point (but AWS NAT Gateway can't route return traffic via TGW)
* Mimics a production-style setup with centralized shared services and isolated application VPCs

---

## Limitations

Due to AWS NAT Gateway limitations, return traffic from the internet **cannot traverse back via the Transit Gateway**. This is why:

* Spoke VPCs cannot access the internet, even if they route `0.0.0.0/0` to the TGW
* A NAT instance or per-VPC NAT Gateway is required to support egress from spoke VPCs
