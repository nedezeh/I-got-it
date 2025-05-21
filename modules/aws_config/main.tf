# ✅ S3 Bucket for AWS Config Logs
resource "aws_s3_bucket" "config_logs" {
  bucket = var.s3_bucket_name
}

# ✅ S3 Bucket Policy for AWS Config
resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AWSConfigBucketPermissionsCheck",
        Effect   = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${aws_s3_bucket.config_logs.bucket}"
      },
      {
        Sid      = "AWSConfigBucketDelivery",
        Effect   = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${aws_s3_bucket.config_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ✅ Caller Identity (for Account ID)
data "aws_caller_identity" "current" {}

# ✅ IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "aws-config-role-new"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ✅ IAM Inline Policy
resource "aws_iam_role_policy" "config_inline_policy" {
  name = "aws-config-inline-policy"
  role = aws_iam_role.config_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "config:Put*",
          "config:Get*",
          "config:Describe*",
          "s3:GetBucketAcl",
          "s3:PutObject"
        ],
        Resource = "*"
      }
    ]
  })
}

# ✅ Configuration Recorder
resource "aws_config_configuration_recorder" "recorder" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

# ✅ Delivery Channel — ✅ FIXED!
resource "aws_config_delivery_channel" "channel" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_logs.bucket

  depends_on = [
    aws_s3_bucket_policy.config_bucket_policy
  ]
}

# ✅ Recorder Status
resource "aws_config_configuration_recorder_status" "status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [
    aws_config_delivery_channel.channel
  ]
}

# ✅ Conformance Pack
resource "aws_config_conformance_pack" "security_conformance_pack" {
  name                = "security-conformance-pack"
  delivery_s3_bucket  = aws_s3_bucket.config_logs.bucket
  template_body       = file("${path.module}/conformance-pack.yaml")

  depends_on = [
    aws_config_configuration_recorder_status.status 
  ]
}        