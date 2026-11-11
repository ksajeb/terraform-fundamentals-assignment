terraform {
  cloud {

    organization = "Learning_purpose-only"

    workspaces {
      name = "terraform-fundamentals-create"
    }
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
