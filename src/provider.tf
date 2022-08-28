terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 4.22.0"
        }
    }
    backend "s3" {
        encrypt = true
        bucket  = "terraform-jaj-infra"
        key     = "jaj-infra-sse-s3"
        region  = "REGION"
    }
}