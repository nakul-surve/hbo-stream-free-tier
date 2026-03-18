terraform {
  backend "s3" {
    bucket         = "hbo-stream-tfstate-845875661791"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "hbo-stream-tfstate-locks"
  }
}
