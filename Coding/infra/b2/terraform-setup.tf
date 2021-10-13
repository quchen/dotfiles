terraform {

  required_version = ">= 1.0.0"
  required_providers {
    b2 = {
      source = "Backblaze/b2"
    }
  }

  backend "s3" {
    bucket   = "tfstate"
    key      = "terraform.tfstate"
    region   = "eu-central-003"
    endpoint = "s3.eu-central-003.backblazeb2.com"

    skip_credentials_validation = true
    skip_region_validation      = true
  }
}

provider "b2" {
}
