resource "aws_ebs_volume" "kafka_storage" {
  count             = length(var.kafka_instance_ids)
  availability_zone = var.availability_zones[count.index]
  size              = 100
  type              = "gp3"
  encrypted         = true
  tags = {
    Name     = "Kafka-Storage-${count.index + 1}"
    Snapshot = "true"
  }
}

resource "aws_volume_attachment" "kafka_attach" {
  count       = length(var.kafka_instance_ids)
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.kafka_storage[count.index].id
  instance_id = var.kafka_instance_ids[count.index]
}

resource "aws_ebs_volume" "container_storage" {
  count             = length(var.container_instance_ids)
  availability_zone = var.availability_zones[count.index]
  size              = 50
  type              = "gp3"
  encrypted         = true
  tags = {
    Name     = "Container-Storage-${count.index + 1}"
    Snapshot = "true"
  }
}

resource "aws_volume_attachment" "container_attach" {
  count       = length(var.container_instance_ids)
  device_name = "/dev/sdg"
  volume_id   = aws_ebs_volume.container_storage[count.index].id
  instance_id = var.container_instance_ids[count.index]
}

resource "aws_ebs_volume" "zookeeper_storage" {
  count             = length(var.zookeeper_instance_ids)
  availability_zone = var.availability_zones[count.index]
  size              = 20
  type              = "gp3"
  encrypted         = true
  tags = {
    Name     = "Zookeeper-Storage-${count.index + 1}"
    Snapshot = "true"
  }
}

resource "aws_volume_attachment" "zookeeper_attach" {
  count       = length(var.zookeeper_instance_ids)
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.zookeeper_storage[count.index].id
  instance_id = var.zookeeper_instance_ids[count.index]
}

resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "dlm-lifecycle-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "dlm.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "dlm_lifecycle_policy" {
  role = aws_iam_role.dlm_lifecycle_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateTags"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_dlm_lifecycle_policy" "ebs_backup" {
  description        = "ebs-backup-policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["VOLUME"]

    target_tags = {
      Snapshot = "true"
    }

    schedule {
      name = "daily-backup"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["03:00"]
      }

      retain_rule {
        count = 7
      }

      copy_tags = true
    }
  }
}
