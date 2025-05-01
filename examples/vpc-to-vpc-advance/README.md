# VPC-to-VPC Advanced Connectivity via Transit Gateway

This Terraform configuration demonstrates a **more advanced VPC-to-VPC pattern** using an **AWS Transit Gateway** with **custom route tables and route propagation**.

## Module Structure

```plaintext
.
├── main.tf                   # This file (root config)
├── modules/
│   └── test-instance/        # Reusable EC2 testing module
```

---

## 🔧 What This Does

* Creates two VPCs (`vpc1` and `vpc2`) in the same region
* Connects them using a shared **Transit Gateway**
* Creates a **custom TGW route table**
* Enables **explicit route association and propagation**
* Adds **VPC route table entries** for inter-VPC communication
* Launches **EC2 instances** in each subnet for connectivity tests

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
terraform apply -var="region=ap-southeast-2" -var="environment=staging"
```

---

## Outputs

After `apply`, you get:

* `test_vpc1`: Instance IDs and private IPs in VPC1
* `test_vpc2`: Same for VPC2

---

## Modules Used

### `cloudbuildlab/vpc/aws`

Used to create minimal, configurable VPCs.

### `modules/test-instance`

Reusable module to:

* Launch 1 EC2 instance per subnet
* Create an EC2 Instance Connect endpoint
* Assign security groups with SSH/ICMP open to your public IP

---

## Test Connectivity

After apply:

```bash
# SSH into instance in VPC1
aws ssm start-session --target <instance-id>

# Ping VPC2 instance
ping 10.2.1.x
```

You can test bidirectional communication between instances in both VPCs.

Make sure your IAM role or user has permissions for EC2 Instance Connect or SSM.

---

## 🚀 What Makes This "Advanced"?

Unlike the basic example:

* **Custom route table** is created for the Transit Gateway (`create_route_table = true`)
* Attachments use `associate_with_route_table` and `propagate_to_route_table`
* Inter-VPC **routing is handled explicitly** with `aws_route_table` resources
* This provides more control and is closer to a production-style setup
