terraform {

  cloud {
    organization = "tf-se-test"

    workspaces {
      name = "ecs-app-blueprint-demo"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.43"
    }
  }

  required_version = ">= 1.1"
}


