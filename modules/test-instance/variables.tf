variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for instance placement"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "tags" {
  description = "Common tags to apply"
  type        = map(string)
}
