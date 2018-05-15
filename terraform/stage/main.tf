provider "google" {
  version = "1.4.0"
  project = "${var.project}"
  region  = "${var.region}"
}

module "app" {
  source            = "../modules/app"
  ssh_user          = "${var.ssh_user}"
  public_key_path   = "${var.public_key_path}"
  private_key_path  = "${var.private_key_path}"
  zone              = "${var.zone}"
  app_disk_image    = "${var.app_disk_image}"
  machine_type      = "${var.machine_type}"
  network           = "${var.network}"
  mongodb_ip        = "${module.db.internal_ip}"
  should_deploy_app = "${var.should_deploy_app}"
}

module "db" {
  source              = "../modules/db"
  ssh_user            = "${var.ssh_user}"
  public_key_path     = "${var.public_key_path}"
  private_key_path    = "${var.private_key_path}"
  zone                = "${var.zone}"
  db_disk_image       = "${var.db_disk_image}"
  machine_type        = "${var.machine_type}"
  network             = "${var.network}"
  should_configure_db = "${var.should_configure_db}"
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["0.0.0.0/0"]
  network       = "${var.network}"
}
