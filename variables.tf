variable "aws_region" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}

variable "tags" {
  type = map(string)

  default = {
    ManagedBy = "Terraform"
  }
}