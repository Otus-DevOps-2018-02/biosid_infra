provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "storage_bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["bckt-001", "my-bucket-83554"]
}

output storage_bucket_url {
  value = "${module.storage_bucket.url}"
}

module "state_bucket" {
  source  = "SweetOps/storage-bucket/google"
  version = "0.1.1"
  name    = ["tf-state-storage-553"]
}

output tf_state_bucket_url {
  value = "${module.state_bucket.url}"
}
