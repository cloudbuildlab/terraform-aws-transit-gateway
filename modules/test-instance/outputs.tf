output "instance_ids" {
  description = "IDs of the launched EC2 instances"
  value       = [for i in aws_instance.this : i.id]
}

output "private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = [for i in aws_instance.this : i.private_ip]
}

output "eic_endpoint_id" {
  description = "ID of the EC2 Instance Connect Endpoint"
  value       = aws_ec2_instance_connect_endpoint.this.id
}

output "eic_endpoint_dns_name" {
  description = "DNS name of the EC2 Instance Connect Endpoint"
  value       = aws_ec2_instance_connect_endpoint.this.dns_name
}
