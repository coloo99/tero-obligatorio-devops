terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Estado remoto en el bucket creado a mano (README, "Preparación única en AWS").
  # use_lockfile: bloqueo nativo de S3, sin tabla de DynamoDB.
  backend "s3" {
    bucket       = "tero-tfstate-coloo99"
    key          = "shared/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "tero"
      ManagedBy = "terraform"
      Stack     = "shared"
    }
  }
}
