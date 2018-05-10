terraform {
  backend "gcs" {
    bucket = "tf-state-storage-553"
    prefix = "terraform/state/stage"
  }
}
