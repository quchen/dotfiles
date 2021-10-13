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

resource "b2_bucket" "backup_2014_windows" {
  bucket_name = "backup-2014-windows-programs-movies-etc"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

module "root_key" {
  source   = "./modules/root_key"
  name     = "s3-compatible"
  filename = "s3-compatible.source"
}

module "key_2020-phantom-linux_backup" {
  source    = "./modules/backup_key"
  name      = "2020-phantom-linux-for-backup-personal-quchen"
  filename  = "2020-phantom-linux-for-backup-personal-quchen.source"
  bucket_id = b2_bucket.backup_personal_quchen.bucket_id
}
