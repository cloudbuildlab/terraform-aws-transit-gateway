# VPC-to-VPC Basic Connectivity via Transit Gateway

This Terraform configuration demonstrates a simple pattern for enabling **private connectivity between two VPCs** using an **AWS Transit Gateway**.

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
* Configures **route tables** for inter-VPC communication
* Launches **EC2 instances** in each subnet for testing
* Enables **EC2 Instance Connect** for SSH access

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

Make sure your IAM role or user has permissions for EC2 Instance Connect or SSM (if preferred).
