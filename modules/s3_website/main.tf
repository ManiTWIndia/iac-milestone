# modules/s3_website/main.tf

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.10.0"

  bucket = "${var.bucket_name_prefix}-static-website-${var.aws_region}"
  acl    = "private"

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  tags = {
    Name        = "${var.bucket_name_prefix}-static-website-bucket"
    Environment = var.environment
  }
}

resource "aws_s3_object" "index_html" {
  bucket       = module.s3_bucket.s3_bucket_id
  key          = "index.html"
  source       = "${path.module}/../../static_website/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/../../static_website/index.html")
}

resource "aws_s3_object" "error_html" {
  bucket       = module.s3_bucket.s3_bucket_id
  key          = "error.html"
  source       = "${path.module}/../../static_website/error.html" 
  content_type = "text/html"
  etag         = filemd5("${path.module}/../../static_website/error.html")
}