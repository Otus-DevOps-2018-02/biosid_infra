variable db_disk_image {
  description = "Disk image for mongo db"
  default     = "reddit-db-base"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-d"
}

variable public_key_path {
  description = "Path to public key used for ssh"
}
