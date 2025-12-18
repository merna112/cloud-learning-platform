variable "availability_zones" {
  type = list(string)
}

variable "kafka_instance_ids" {
  type = list(string)
}

variable "container_instance_ids" {
  type = list(string)
}

variable "zookeeper_instance_ids" {
  type = list(string)
}
