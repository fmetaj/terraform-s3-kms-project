output "bucket_id" {
  description = "S3 bucket ID"
  value       = aws_s3_bucket.this.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.this.arn
}

output "bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "bucket_domain_name" {
  description = "S3 bucket domain name"
  value       = aws_s3_bucket.this.bucket_domain_name
}

output "kms_key_arn" {
  description = "KMS Key ARN"
  value       = aws_kms_key.s3_kms.arn
}

output "kms_key_id" {
  description = "KMS Key ID"
  value       = aws_kms_key.s3_kms.key_id
}