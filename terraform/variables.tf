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

variable public_key_path {
  description = "Path to public key used for ssh"
}

variable private_key_path {
  description = "Path to private key used for ssh by provisioners' connection"
}

variable disk_image {
  description = "Disk image"
}
