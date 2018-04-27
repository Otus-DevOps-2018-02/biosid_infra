resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-db"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.db_disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    network       = "${var.network}"
    access_config = {}
  }

  metadata {
    ssh-keys = "sologm:${file("${var.public_key_path}")}"
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-${var.network}"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  # правило применимо к инстансам с тегом ...
  target_tags = ["reddit-db"]

  # порт будет доступен только для инстансов с тегом ...
  source_tags = ["reddit-app"]
}
