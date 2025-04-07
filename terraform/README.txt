This Terraform module creates a complete AWS infrastructure with VPC, subnets, EC2 instances, load balancing, and auto-scaling capabilities.
Features
Networking:

VPC with public and private subnets across multiple availability zones

Internet Gateway for public subnet internet access

NAT Gateways for private subnet outbound internet access

Route tables with appropriate routes

Compute:

EC2 instances in public subnets with web servers

Auto Scaling Group for horizontal scaling

Launch template for consistent instance configuration

Storage:

EBS volumes attached to EC2 instances

Encryption enabled for all volumes

Load Balancing:

Application Load Balancer (ALB) distributing traffic to instances

Target group with health checks

Listener configuration for HTTP traffic

Security:

Security groups for instances and ALB

Restricted ingress ports with configurable rules

Egress rules for controlled outbound traffic

Configuration
Customize the infrastructure by modifying these variables in variables.auto.tfvars.tf:


variable "public" {
  type = map(any)
  default = {
    us-west-1a = "10.0.10.0/24"
    us-west-1c = "10.0.20.0/24"
  }
}

variable "private" {
  type = map(any)
  default = {
    us-west-1a = "10.0.100.0/24"
    us-west-1c = "10.0.200.0/24"
  }
}

variable "AZ" {
  type    = list(any)
  default = ["us-west-1a", "us-west-1c"]
}

variable "ports" {
  type    = map(any)
  default = { http = "80", https = "443", ssh = "22" }
}

variable "ports_ALB" {
  type    = map(any)
  default = { http = "80", https = "443" }
}


Outputs
After applying the configuration, Terraform will output:

Load Balancer public IPs (lb)

EC2 instance public IPs (ip_1, ip_2)

ALB DNS name (ALB_dns_name)
