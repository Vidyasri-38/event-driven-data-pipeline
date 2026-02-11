terraform {
  backend "s3" {
    bucket         = "terraform-state-vidya"
    key            = "data-pipeline/terraform.tfstate"
    region         = "ap-south-2"
    dynamodb_table = "terraform-lock-table"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-2"
}
