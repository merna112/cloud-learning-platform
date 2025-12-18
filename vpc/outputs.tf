output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "data_subnet_ids" {
  value = aws_subnet.data[*].id
}

output "kafka_subnet_ids" {
  value = aws_subnet.kafka[*].id
}

output "security_group_ids" {
  value = {
    alb_sg        = aws_security_group.alb.id
    containers_sg = aws_security_group.containers.id
    rds_sg        = aws_security_group.rds.id
    kafka_sg      = aws_security_group.kafka.id
  }
}

output "nacl_ids" {
  value = {
    public  = aws_network_acl.public_nacl.id
    private = aws_network_acl.private_nacl.id
    data    = aws_network_acl.data_nacl.id
    kafka   = aws_network_acl.kafka_nacl.id
  }
}

output "nat_gateway_ips" {
  value = aws_eip.nat[*].public_ip
}


output "container_sg_id" {
  value = aws_security_group.containers.id
}

output "kafka_sg_id" {
  value = aws_security_group.kafka.id
}

output "zookeeper_sg_id" {
  value = aws_security_group.kafka.id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}

output "availability_zones" {
  value = var.availability_zones
}

output "lambda_sg_id" {
  value = aws_security_group.lambda.id
}
