
terraform {
  required_version = ">= 1.1"

  required_providers {
    aws = {
      version = ">= 3.63"
      source  = "hashicorp/aws"
      version = ">= 4.9"
    }
  }
}
