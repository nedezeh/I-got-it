terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cloudtrail" {
  source      = "./modules/cloudtrail"
  bucket_name = "ezeh1-cloudtrail-bucket-2025xyz"
  trail_name  = "john-cloudtrail-0521xyz"
}

module "aws_config" {
  source           = "./modules/aws_config"
  s3_bucket_name   = "ned2-config-logs-bucket-2025xyz"
}

module "guardduty" {
  source = "./modules/guardduty"
}

module "securityhub" {
  source = "./modules/securityhub"
}        