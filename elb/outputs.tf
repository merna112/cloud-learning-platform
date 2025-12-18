output "alb_dns_name" {
  value = aws_lb.api_alb.dns_name
}

output "nlb_dns_name" {
  value = aws_lb.kafka_nlb.dns_name
}

output "microservice_tg_arn" {
  value = aws_lb_target_group.microservice_tg.arn
}

output "kafka_tg_arn" {
  value = aws_lb_target_group.kafka_tg.arn
}
