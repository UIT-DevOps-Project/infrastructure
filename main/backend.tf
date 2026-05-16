terraform {
  backend "s3" {
    bucket         = "uit-devops-nt548-tfstate"
    key            = "main/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "uit-devops-nt548-tfstate-lock"
    encrypt        = true
  }
}
