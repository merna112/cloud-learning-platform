resource "aws_lambda_layer_version" "common_utils" {
  filename            = "common_layer.zip"
  layer_name          = "common_dependencies"
  compatible_runtimes = ["python3.9"]
}

resource "aws_cloudwatch_log_group" "s3_processor_logs" {
  name              = "/aws/lambda/s3-event-processor"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "cleanup_logs" {
  name              = "/aws/lambda/scheduled-cleanup-task"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "kafka_monitor_logs" {
  name              = "/aws/lambda/kafka-consumer-monitor"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_group" "scaling_logs" {
  name              = "/aws/lambda/automated-scaling-decisions"
  retention_in_days = 14
}

resource "aws_lambda_function" "s3_processor" {
  filename      = "s3_processor.zip"
  function_name = "s3-event-processor"
  role          = var.lambda_exec_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 60
  memory_size  = 256
  layers        = [aws_lambda_layer_version.common_utils.arn]

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      ENV = var.env
    }
  }

  depends_on = [aws_cloudwatch_log_group.s3_processor_logs]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.s3_bucket_arn
}

resource "aws_s3_bucket_notification" "s3_trigger" {
  bucket = var.s3_bucket_name

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_processor.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_function" "cleanup_task" {
  filename      = "cleanup.zip"
  function_name = "scheduled-cleanup-task"
  role          = var.lambda_exec_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 300
  memory_size  = 256

  environment {
    variables = {
      ENV = var.env
    }
  }

  depends_on = [aws_cloudwatch_log_group.cleanup_logs]
}

resource "aws_cloudwatch_event_rule" "cleanup_schedule" {
  name                = "lambda-cleanup-rule"
  schedule_expression = "rate(24 hours)"
}

resource "aws_cloudwatch_event_target" "cleanup_target" {
  rule = aws_cloudwatch_event_rule.cleanup_schedule.name
  arn  = aws_lambda_function.cleanup_task.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cleanup_task.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.cleanup_schedule.arn
}

resource "aws_lambda_function" "kafka_monitor" {
  filename      = "kafka_monitor.zip"
  function_name = "kafka-consumer-monitor"
  role          = var.lambda_exec_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 120
  memory_size  = 256

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [var.lambda_sg_id]
  }

  environment {
    variables = {
      ENV = var.env
    }
  }

  depends_on = [aws_cloudwatch_log_group.kafka_monitor_logs]
}

resource "aws_lambda_function" "scaling_decision" {
  filename      = "scaling.zip"
  function_name = "automated-scaling-decisions"
  role          = var.lambda_exec_role_arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 120
  memory_size  = 256

  environment {
    variables = {
      ENV = var.env
    }
  }

  depends_on = [aws_cloudwatch_log_group.scaling_logs]
}
