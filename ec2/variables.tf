variable "ami_id" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "container_sg_id" {
  type = string
}

variable "kafka_sg_id" {
  type = string
}

variable "zookeeper_sg_id" {
  type = string
}

variable "ec2_instance_profile_name" {
  type = string
}

variable "alert_email" {
  type = string
}
