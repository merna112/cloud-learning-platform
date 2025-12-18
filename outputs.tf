output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

# output "alb_dns_name" {
#   value = module.elb.alb_dns_name
# }

# output "kafka_nlb_dns_name" {
#   value = module.elb.nlb_dns_name
# }

# output "s3_bucket_names" {
#   value = module.s3.bucket_names
# }

# output "database_endpoints" {
#   value = module.rds.database_endpoints
# }

output "lambda_arns" {
  value = module.lambda.lambda_arns
}
