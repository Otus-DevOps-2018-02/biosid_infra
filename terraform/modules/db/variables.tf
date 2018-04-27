variable db_disk_image {
  description = "Disk image for mongo db"
  default     = "reddit-db-base"
}

variable zone {
  description = "Zone"
}

variable public_key_path {
  description = "Path to public key used for ssh"
}

variable machine_type {
  description = "Machine type"
}

variable network {
  description = "Network name"
}