terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
  availability_zones = var.availability_zones
}

module "iam" {
  source = "./iam"
}

module "ec2" {
  source = "./ec2"
  vpc_id                    = module.vpc.vpc_id 
  private_subnet_ids        = module.vpc.private_subnet_ids
  container_sg_id           = module.vpc.container_sg_id
  kafka_sg_id               = module.vpc.kafka_sg_id
  zookeeper_sg_id           = module.vpc.zookeeper_sg_id
  ec2_instance_profile_name = module.iam.ec2_instance_profile_name
  alert_email               = var.alert_email
  ami_id                    = var.ami_id
}

module "ebs" {
  source                 = "./ebs"
  availability_zones     = module.vpc.availability_zones
  kafka_instance_ids     = module.ec2.kafka_asg_id
  container_instance_ids = module.ec2.container_asg_id
  zookeeper_instance_ids = module.ec2.zookeeper_asg_id
}


module "elb" {
  source              = "./elb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  alb_sg_id           = module.vpc.alb_sg_id
  acm_certificate_arn = var.acm_certificate_arn
}

module "s3" {
  source     = "./s3"
  env        = var.env
  account_id = var.account_id
}

module "lambda" {
  source = "./lambda"
  lambda_exec_role_arn = module.iam.lambda_exec_role_arn
  private_subnet_ids   = module.vpc.private_subnet_ids
  lambda_sg_id         = module.vpc.lambda_sg_id
  s3_bucket_arn  = module.s3.bucket_arns[0]
  s3_bucket_name = module.s3.bucket_names[0]
  env = "dev"
}



module "rds" {
  source          = "./rds"
  data_subnet_ids = module.vpc.data_subnet_ids
  rds_sg_id       = module.vpc.rds_sg_id
  db_password     = var.db_password
}
