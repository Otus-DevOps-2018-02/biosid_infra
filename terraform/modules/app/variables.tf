variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
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
