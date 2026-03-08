provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}

resource "aws_s3_bucket" "terraform_bucket_1" {
    bucket = "terraform-bucket-test-isolation-1"

    # prevenir une suppression accidentelle du bucket
    lifecycle {
        prevent_destroy = true
    }
}

resource "aws_s3_versioning" "versioning" {
    bucket = aws_s3_bucket.terraform_bucket_1.id

    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_server_side_encryption_configuration" "encryption" {
    bucket = aws_s3_bucket.terraform_bucket_1.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

resource "aws_dynamodb_table" "terraform_table_1" {
    name         = "terraform-table-test-isolation-1"
    # billing_mode = "PAY_PER_REQUEST"
    hash_key     = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }

    # prevenir une suppression accidentelle de la table
    lifecycle {
        prevent_destroy = true
    }
}

terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "terraform-bucket-test-isolation-1"
    key            = "workspaces-example/terraform.tfstate"
    region         = "us-east-2"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "terraform-table-test-isolation-1"
    encrypt        = true
  }
}