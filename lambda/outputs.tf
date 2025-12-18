output "lambda_arns" {
  value = {
    s3_processor     = aws_lambda_function.s3_processor.arn
    cleanup_task     = aws_lambda_function.cleanup_task.arn
    kafka_monitor    = aws_lambda_function.kafka_monitor.arn
    scaling_decision = aws_lambda_function.scaling_decision.arn
  }
}
