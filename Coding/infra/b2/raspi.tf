resource "b2_bucket" "backup_raspi" {
  bucket_name = "backup-2020-iot-raspi"
  bucket_type = "allPrivate"

  lifecycle_rules {
    file_name_prefix             = ""
    days_from_hiding_to_deleting = 1
  }
}

# Key for Raspi’s own backups directly to B2
module "key_backup_2020-iot-raspi" {
  source    = "./modules/backup_key"
  name      = "2020-raspi-self-backup"
  filename  = "pineapple/2020-raspi-self-backup.source"
  bucket_id = b2_bucket.backup_raspi.bucket_id
}

# Raspi’s capability to upload all backups from the HDD
module "key_backup_2020-iot-raspi_upload_backups" {
  source    = "./modules/backup_key"
  name      = "2020-raspi-backups-upload"
  filename  = "pineapple/2020-raspi-backups-upload.source"
  bucket_id = null # allow access to all buckets
}
