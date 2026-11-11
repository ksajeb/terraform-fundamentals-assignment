terraform {
   cloud {

    organization = "Learning_purpose-only"

    workspaces {
      name = "terraform-fundamentals-manage"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.72.0"
    }
  }

  required_version = ">= 1.2.0"
}
