############################################
# KMS KEY
############################################

resource "aws_kms_key" "s3_kms" {
  description             = "KMS key for S3 bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(
    var.tags,
    {
      Name        = "s3-kms-key"
      Environment = var.environment
    }
  )
}

############################################
# KMS ALIAS
############################################

resource "aws_kms_alias" "s3_alias" {
  name          = "alias/${var.bucket_name}-key"
  target_key_id = aws_kms_key.s3_kms.key_id
}

############################################
# S3 BUCKET
############################################

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
    }
  )
}

############################################
# VERSIONING
############################################

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

############################################
# SERVER SIDE ENCRYPTION (KMS)
############################################

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {

  bucket = aws_s3_bucket.this.id

  rule {

    bucket_key_enabled = true

    apply_server_side_encryption_by_default {

      sse_algorithm = "aws:kms"

      kms_master_key_id = aws_kms_key.s3_kms.arn
    }
  }
}

############################################
# BLOCK PUBLIC ACCESS
############################################

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

############################################
# OWNERSHIP CONTROLS
############################################

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

############################################
# LIFECYCLE CONFIGURATION
############################################

resource "aws_s3_bucket_lifecycle_configuration" "this" {

  bucket = aws_s3_bucket.this.id

  rule {

    id = "cleanup-old-versions"

    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 30
    }

    expiration {
      days = 90
    }
  }
}

############################################
# BUCKET POLICY
############################################

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "DenyInsecureTransport"
        Effect = "Deny"

        Principal = "*"

        Action = "s3:*"

        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },

      {
        Sid    = "EnforceKMS"
        Effect = "Deny"

        Principal = "*"

        Action = "s3:PutObject"

        Resource = "${aws_s3_bucket.this.arn}/*"

        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
            "s3:x-amz-server-side-encryption-aws-kms-key-id" = aws_kms_key.s3_kms.arn
          }
        }
      }
    ]
  })
}
resource "aws_kms_key_policy" "this" {
  key_id = aws_kms_key.s3_kms.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [

      {
        Sid    = "EnableIAMPermissions"
        Effect = "Allow"

        Principal = {
          AWS = "*"
        }

        Action = "kms:*"

        Resource = "*"
      }

    ]
  })
}