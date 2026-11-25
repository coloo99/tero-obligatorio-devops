terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Un mismo backend para los tres ambientes: cada workspace (dev, test, prod)
  # guarda su estado en envs/<workspace>/tero.tfstate dentro del bucket.
  backend "s3" {
    bucket               = "tero-tfstate-coloo99"
    key                  = "tero.tfstate"
    workspace_key_prefix = "envs"
    region               = "us-east-1"
    encrypt              = true
    use_lockfile         = true
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = "tero"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
