terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_sns_topic" "alerts" {
  name = "platform-alerts-topic"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = "mernaadel182@gmail.com"
}


resource "aws_cloudwatch_log_group" "container_logs" {
  name              = "/aws/ec2/container-platform"
  retention_in_days = 7
}

resource "aws_launch_template" "container_lt" {
  name_prefix   = "container-host-lt-"
  image_id      = var.ami_id
  instance_type = "t3.medium"

  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.container_sg_id]
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<EOF
#!/bin/bash
apt-get update -y
apt-get install -y docker.io containerd awscli
systemctl enable --now docker
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
apt-get install -y kubelet kubeadm kubectl
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Container-Host"
    }
  }
}

resource "aws_launch_template" "kafka_lt" {
  name_prefix   = "kafka-broker-lt-"
  image_id      = var.ami_id
  instance_type = "t3.medium"

  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.kafka_sg_id]
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<EOF
#!/bin/bash
apt-get update -y
apt-get install -y default-jdk awscli
wget https://downloads.apache.org/kafka/3.5.0/kafka_2.13-3.5.0.tgz
tar -xzf kafka_2.13-3.5.0.tgz
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Kafka-Broker"
    }
  }
}

resource "aws_launch_template" "zookeeper_lt" {
  name_prefix   = "zookeeper-lt-"
  image_id      = var.ami_id
  instance_type = "t3.small"

  iam_instance_profile {
    name = var.ec2_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [var.zookeeper_sg_id]
  }

  monitoring {
    enabled = true
  }

  user_data = base64encode(<<EOF
#!/bin/bash
apt-get update -y
apt-get install -y default-jdk awscli
EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Zookeeper-Node"
    }
  }
}

resource "aws_autoscaling_group" "container_asg" {
  name                      = "container-asg"
  desired_capacity          = 3
  max_size                  = 5
  min_size                  = 3
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.container_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "kafka_asg" {
  name                      = "kafka-asg"
  desired_capacity          = 3
  max_size                  = 4
  min_size                  = 3
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.kafka_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_group" "zookeeper_asg" {
  name                      = "zookeeper-asg"
  desired_capacity          = 3
  max_size                  = 3
  min_size                  = 3
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.zookeeper_lt.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "container_policy" {
  name                   = "container-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.container_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_autoscaling_policy" "kafka_policy" {
  name                   = "kafka-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.kafka_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

resource "aws_autoscaling_policy" "zookeeper_policy" {
  name                   = "zookeeper-cpu-policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.zookeeper_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80.0
  }
}

resource "aws_cloudwatch_metric_alarm" "container_cpu_alarm" {
  alarm_name          = "container-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.container_asg.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "kafka_cpu_alarm" {
  alarm_name          = "kafka-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.kafka_asg.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "zookeeper_cpu_alarm" {
  alarm_name          = "zookeeper-cpu-alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 80

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.zookeeper_asg.name
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
