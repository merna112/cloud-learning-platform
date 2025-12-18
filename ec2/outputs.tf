output "container_asg_id" {
  value = aws_autoscaling_group.container_asg.id
}

output "kafka_asg_id" {
  value = aws_autoscaling_group.kafka_asg.id
}

output "zookeeper_asg_id" {
  value = aws_autoscaling_group.zookeeper_asg.id
}

output "sns_topic_arn" {
  value = aws_sns_topic.alerts.arn
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.container_logs.name
}
