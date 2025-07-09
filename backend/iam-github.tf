data "aws_caller_identity" "current" {}

locals {
  github_oidc_already_exists = true
}

resource "aws_iam_openid_connect_provider" "github_actions_role" {
  count = local.github_oidc_already_exists ? 0 : 1
  url   = "https://token.actions.githubusercontent.com"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
}

resource "aws_iam_role" "github_actions_role" {
  name = "${var.prefix}-github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = format("arn:aws:iam::%s:oidc-provider/token.actions.githubusercontent.com", data.aws_caller_identity.current.id)
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:ManiTWIndia/iac-milestone:*"
          },
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })

  tags = {
    Name        = "${var.prefix}-github-actions-role"
    Environment = var.env
  }
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "${var.prefix}-github-actions-policy"
  description = "Permissions for GitHub Actions to deploy/destroy Terraform resources"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "ec2:Describe*",
          "lambda:*",
          "apigateway:*",
          "apigatewayv2:*",
          "dynamodb:*",
          "s3:*",
          "logs:*",
          "iam:ListRoles",
          "iam:ListPolicies",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:GetRole",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:PassRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "github_actions_iam_access" {
  name = "GitHubActions_IAM_Access"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetPolicy",
          "iam:GetPolicyVersion"
        ]
        Resource = "arn:aws:iam::160071257600:policy/mani-iac-milestone-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_role.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

output "github_actions_role_arn" {
  description = "ARN of the IAM role for GitHub Actions."
  value       = aws_iam_role.github_actions_role.arn
}