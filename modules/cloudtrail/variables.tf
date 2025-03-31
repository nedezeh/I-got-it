variable "bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  type        = string
}

variable "trail_name" {
  description = "Name of the CloudTrail trail"
  type        = string
}