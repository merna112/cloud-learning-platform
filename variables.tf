variable "aws_region" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "alert_email" {
  type = string
}

variable "ec2_instance_profile_name" {
  type = string
}

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}


variable "env" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM certificate ARN for ALB and HTTPS listener"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  sensitive   = true
}
