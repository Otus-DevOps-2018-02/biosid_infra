variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone"
  default     = "europe-west1-d"
}

variable ssh_user {
  description = "User name used fro ssh"
}

variable public_key_path {
  description = "Path to public key used for ssh"
}

variable private_key_path {
  description = "Path to private key used for ssh by provisioners' connection"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for mongo db"
  default     = "reddit-db-base"
}

variable machine_type {
  description = "Machine type"
  default     = "g1-small"
}

variable network {
  description = "Network name"
  default     = "default"
}

variable should_deploy_app {
  description = "Should application to be deployed on server or not"
  default     = "true"
}

variable should_configure_db {
  description = "Should configure MongoDb server or not"
  default     = "true"
}
