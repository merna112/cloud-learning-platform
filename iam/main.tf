locals {
  developer_names = ["Abdallah", "Antonious", "Remonda", "Nourhan", "Nora"]
}

data "aws_iam_policy_document" "lambda_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}


# --- Users & Groups ---
resource "aws_iam_user" "developers" {
  for_each = toset(local.developer_names)
  name     = each.value
}

resource "aws_iam_user" "admin_user" {
  name = "Merna"
}

resource "aws_iam_group" "dev_group" {
  name = "development-team"
}

resource "aws_iam_group" "admin_group" {
  name = "admin-team"
}

resource "aws_iam_group_membership" "dev_membership" {
  name  = "dev-group-membership"
  users = [for u in aws_iam_user.developers : u.name]
  group = aws_iam_group.dev_group.name
}

resource "aws_iam_group_membership" "admin_membership" {
  name  = "admin-group-membership"
  users = [aws_iam_user.admin_user.name]
  group = aws_iam_group.admin_group.name
}

# --- Admin & Developer Custom Policies ---
resource "aws_iam_policy" "admin_custom_policy" {
  name        = "AdministratorCustomPolicy"
  description = "Full access policy for administrator"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "*", Effect = "Allow", Resource = "*" }]
  })
}

resource "aws_iam_policy" "dev_custom_policy" {
  name        = "DeveloperCustomPolicy"
  description = "Access to all services except IAM"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "*"
      Effect = "Allow"
      NotAction = ["iam:*", "organizations:*", "account:*"]
      Resource = "*"
    }]
  })
}

resource "aws_iam_group_policy_attachment" "admin_attach" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.admin_custom_policy.arn
}

resource "aws_iam_group_policy_attachment" "dev_attach" {
  group      = aws_iam_group.dev_group.name
  policy_arn = aws_iam_policy.dev_custom_policy.arn
}

# --- EC2 Role & Policy ---
resource "aws_iam_role" "ec2_service_role" {
  name = "ec2_platform_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_policy" "ec2_access_policy" {
  name = "EC2AccessS3RDSPolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"], Effect = "Allow", Resource = "*" },
      { Action = ["rds-db:connect", "rds:DescribeDBInstances"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_attach" {
  role       = aws_iam_role.ec2_service_role.name
  policy_arn = aws_iam_policy.ec2_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_service_role.name
}

# --- Lambda Role & Policy (Corrected) ---
resource "aws_iam_role" "lambda_service_role" {
  name = "lambda_platform_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "lambda.amazonaws.com" } }]
  })
}

resource "aws_iam_policy" "lambda_custom_policy" {
  name = "LambdaServicePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"], Effect = "Allow", Resource = "arn:aws:logs:*:*:*" },
      { Action = ["s3:GetObject"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_attach" {
  role       = aws_iam_role.lambda_service_role.name
  policy_arn = aws_iam_policy.lambda_custom_policy.arn
}

# --- Container Role & Policy (Corrected) ---
resource "aws_iam_role" "container_service_role" {
  name = "container_service_account_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" } }]
  })
}

resource "aws_iam_policy" "container_custom_policy" {
  name = "ContainerServicePolicy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Action = ["ecr:GetAuthorizationToken", "ecr:BatchCheckLayerAvailability", "ecr:GetDownloadUrlForLayer", "ecr:BatchGetImage"], Effect = "Allow", Resource = "*" }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "container_attach" {
  role       = aws_iam_role.container_service_role.name
  policy_arn = aws_iam_policy.container_custom_policy.arn
}

# --- MFA Security Enforcement ---
resource "aws_iam_policy" "mfa_enforcement" {
  name = "ForceMFA"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      { Sid = "AllowViewAccountInfo", Effect = "Allow", Action = ["iam:GetAccountPasswordPolicy", "iam:ListVirtualMFADevices"], Resource = "*" },
      { Sid = "DenyAllExceptListedIfNoMFA", Effect = "Deny", NotAction = ["iam:CreateVirtualMFADevice", "iam:EnableMFADevice", "iam:GetUser", "iam:ListMFADevices", "iam:ListVirtualMFADevices", "iam:ResyncMFADevice", "sts:GetSessionToken"], Resource = "*", Condition = { BoolIfExists = { "aws:MultiFactorAuthPresent" = "false" } } }
    ]
  })
}

resource "aws_iam_group_policy_attachment" "admin_mfa_attach" {
  group      = aws_iam_group.admin_group.name
  policy_arn = aws_iam_policy.mfa_enforcement.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume.json
}
