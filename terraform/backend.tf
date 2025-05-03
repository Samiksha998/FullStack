terraform {
  backend "s3" {
    bucket = "tumbin"
    region = "us-east-1"
    key = "eks/terraform.tfstate"
  }
}
