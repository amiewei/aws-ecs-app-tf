terraform {

  cloud {
    organization = "tf-se-test"

    workspaces {
      name = "ecs-app-dev"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14.0"
}
