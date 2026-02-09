terraform {
  required_version = ">= 1.6"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


 #backend "s3" {
  #    bucket         = "upwind-terraform-state-002757291574"
   #   key            = "prod/terraform.tfstate"
    #  region         = "us-east-1"
     # dynamodb_table = "upwind-terraform-locks"
      #encrypt        = true
   # }
}