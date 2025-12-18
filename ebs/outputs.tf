output "kafka_volume_ids" {
  value = aws_ebs_volume.kafka_storage[*].id
}

output "container_volume_ids" {
  value = aws_ebs_volume.container_storage[*].id
}

output "zookeeper_volume_ids" {
  value = aws_ebs_volume.zookeeper_storage[*].id
}

output "dlm_policy_id" {
  value = aws_dlm_lifecycle_policy.ebs_backup.id
}
