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

variable private_key_path {
  description = "Path to private key used for ssh by provisioners' connection"
}

variable ssh_user {
  description = "User name user for ssh"
}

variable machine_type {
  description = "Machine type"
}

variable network {
  description = "Network name"
}
