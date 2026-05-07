aws_region  = "us-east-1"
bucket_name = "amazon-s3-prod-bucket-fiona"

environment = "prod"

enable_versioning = true

tags = {
  Project     = "S3BUCKET"
  Owner       = "cloud-team"
  Environment = "prod"
}