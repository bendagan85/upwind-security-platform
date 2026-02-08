terraform {
  required_version = ">= 1.6"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Comment this out for initial setup, uncomment after creating S3 bucket
  # backend "s3" {
  #   bucket         = "upwind-terraform-state-CHANGE_ME"
  #   key            = "prod/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "upwind-terraform-locks"
  #   encrypt        = true
  # }
}