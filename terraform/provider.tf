provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "upwind-security"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}