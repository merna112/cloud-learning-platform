output "developer_user_names" {
  value = [for u in aws_iam_user.developers : u.name]
}

output "admin_user_name" {
  value = aws_iam_user.admin_user.name
}

output "ec2_role_arn" {
  value = aws_iam_role.ec2_service_role.arn
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_service_role.arn
}

output "container_role_arn" {
  value = aws_iam_role.container_service_role.arn
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "policy_jsons" {
  value = {
    ec2_policy       = aws_iam_policy.ec2_access_policy.policy
    lambda_policy    = aws_iam_policy.lambda_custom_policy.policy
    container_policy = aws_iam_policy.container_custom_policy.policy
    dev_policy       = aws_iam_policy.dev_custom_policy.policy
    admin_policy     = aws_iam_policy.admin_custom_policy.policy
    mfa_policy       = aws_iam_policy.mfa_enforcement.policy
  }
}

output "lambda_exec_role_arn" {
  value = aws_iam_role.lambda_exec.arn
}
