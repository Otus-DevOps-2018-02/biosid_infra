provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage-bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["bckt-001"]
}

output storage-bucket_url {
  value = "${module.storage-bucket.url}"
}

module "storage-bucket-us" {
  source   = "SweetOps/storage-bucket/google"
  version  = "0.1.1"
  name     = ["bckt-002-us", "bckt-003-us"]
  location = "us-central1"
}

output storage-bucket_url_us {
  value = "${module.storage-bucket-us.url}"
}
