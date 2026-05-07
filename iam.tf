############################################
# IAM USER
############################################

resource "aws_iam_user" "s3_user" {
  name = "s3-upload-user"
}

############################################
# IAM POLICY ATTACHED TO USER
############################################

resource "aws_iam_user_policy" "s3_policy" {
  name = "s3-upload-policy"
  user = aws_iam_user.s3_user.name

  policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      ####################################
      # S3 ACCESS
      ####################################

      {
        Effect = "Allow"

        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]

        Resource = [
          "arn:aws:s3:::amazon-s3-prod-bucket-fiona",
          "arn:aws:s3:::amazon-s3-prod-bucket-fiona/*"
        ]
      },

      ####################################
      # KMS ACCESS (NEEDED FOR SSE-KMS)
      ####################################

      {
        Effect = "Allow"

        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]

        Resource = "*"
      }

    ]
  })
}