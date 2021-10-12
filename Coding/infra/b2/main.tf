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

resource "b2_bucket" "tfstate" {
  bucket_name = "tfstate"
  bucket_type = "allPrivate"
}

resource "b2_bucket" "backup_personal_quchen" {
  bucket_name = "backup-personal-quchen"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

resource "b2_bucket" "backup_raspi" {
  bucket_name = "backup-2020-iot-raspi"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

resource "b2_bucket" "backup_2014_windows" {
  bucket_name = "backup-2014-windows-programs-movies-etc"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

module "root_key" {
  source = "./modules/root_key"
  name   = "s3-compatible"
}

module "pineapple_root_key" {
  source = "./modules/root_key"
  name   = "pineapple"
}

module "key_2020-phantom-linux_backup" {
  source    = "./modules/backup_key"
  name      = "2020-phantom-linux-for-backup-personal-quchen"
  bucket_id = b2_bucket.backup_personal_quchen.bucket_id
}

module "key_backup_2020-iot-raspi" {
  source    = "./modules/backup_key"
  name      = "2020-raspi-backup"
  bucket_id = b2_bucket.backup_raspi.bucket_id
}
