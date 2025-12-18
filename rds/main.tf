resource "aws_db_subnet_group" "rds_subnets" {
  name       = "main-rds-subnet-group"
  subnet_ids = var.data_subnet_ids
}

resource "aws_db_parameter_group" "pg_optimized" {
  name   = "rds-pg-optimized"
  family = "postgres15"

  parameter {
    name  = "log_connections"
    value = "1"
  }
}

resource "aws_db_instance" "user_db" {
  identifier                   = "user-management-db"
  engine                       = "postgres"
  engine_version               = "15.4"
  instance_class               = "db.t3.medium"
  allocated_storage            = 20
  storage_type                 = "gp3"
  db_name                      = "user_db"
  username                     = "dbadmin"
  password                     = var.db_password
  db_subnet_group_name          = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids        = [var.rds_sg_id]
  multi_az                     = true
  storage_encrypted             = true
  backup_retention_period       = 7
  backup_window                 = "03:00-04:00"
  maintenance_window            = "sun:04:00-sun:05:00"
  parameter_group_name          = aws_db_parameter_group.pg_optimized.name
  monitoring_interval           = 60
  performance_insights_enabled  = true
  publicly_accessible           = false
  deletion_protection           = true
  final_snapshot_identifier     = "user-management-db-final"
}

resource "aws_db_instance" "chat_db" {
  identifier                   = "chat-service-db"
  engine                       = "postgres"
  engine_version               = "15.4"
  instance_class               = "db.t3.medium"
  allocated_storage            = 20
  storage_type                 = "gp3"
  db_name                      = "chat_db"
  username                     = "dbadmin"
  password                     = var.db_password
  db_subnet_group_name          = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids        = [var.rds_sg_id]
  multi_az                     = true
  storage_encrypted             = true
  backup_retention_period       = 7
  backup_window                 = "03:00-04:00"
  maintenance_window            = "sun:04:00-sun:05:00"
  parameter_group_name          = aws_db_parameter_group.pg_optimized.name
  monitoring_interval           = 60
  performance_insights_enabled  = true
  publicly_accessible           = false
  deletion_protection           = true
  final_snapshot_identifier     = "chat-service-db-final"
}

resource "aws_db_instance" "chat_db_replica" {
  identifier                  = "chat-service-db-replica"
  replicate_source_db          = aws_db_instance.chat_db.identifier
  instance_class              = "db.t3.medium"
  storage_type                = "gp3"
  allocated_storage           = 20
  publicly_accessible          = false
  deletion_protection          = true
  performance_insights_enabled = true
  monitoring_interval          = 60
  vpc_security_group_ids       = [var.rds_sg_id]
  db_subnet_group_name         = aws_db_subnet_group.rds_subnets.name
  backup_retention_period     = 7
  skip_final_snapshot          = true
}


resource "aws_db_instance" "document_db" {
  identifier                   = "document-reader-db"
  engine                       = "postgres"
  engine_version               = "15.4"
  instance_class               = "db.t3.medium"
  allocated_storage            = 20
  storage_type                 = "gp3"
  db_name                      = "document_db"
  username                     = "dbadmin"
  password                     = var.db_password
  db_subnet_group_name          = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids        = [var.rds_sg_id]
  multi_az                     = true
  storage_encrypted             = true
  backup_retention_period       = 7
  backup_window                 = "03:00-04:00"
  maintenance_window            = "sun:04:00-sun:05:00"
  parameter_group_name          = aws_db_parameter_group.pg_optimized.name
  monitoring_interval           = 60
  performance_insights_enabled  = true
  publicly_accessible           = false
  deletion_protection           = true
  final_snapshot_identifier     = "document-reader-db-final"
}

resource "aws_db_instance" "quiz_db" {
  identifier                   = "quiz-service-db"
  engine                       = "postgres"
  engine_version               = "15.4"
  instance_class               = "db.t3.medium"
  allocated_storage            = 20
  storage_type                 = "gp3"
  db_name                      = "quiz_db"
  username                     = "dbadmin"
  password                     = var.db_password
  db_subnet_group_name          = aws_db_subnet_group.rds_subnets.name
  vpc_security_group_ids        = [var.rds_sg_id]
  multi_az                     = true
  storage_encrypted             = true
  backup_retention_period       = 7
  backup_window                 = "03:00-04:00"
  maintenance_window            = "sun:04:00-sun:05:00"
  parameter_group_name          = aws_db_parameter_group.pg_optimized.name
  monitoring_interval           = 60
  performance_insights_enabled  = true
  publicly_accessible           = false
  deletion_protection           = true
  final_snapshot_identifier     = "quiz-service-db-final"
}
