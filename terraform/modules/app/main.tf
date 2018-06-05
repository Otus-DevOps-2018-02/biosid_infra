resource "google_compute_instance" "app" {
  name         = "reddit-app"
  machine_type = "${var.machine_type}"
  zone         = "${var.zone}"
  tags         = ["reddit-app", "http-server"]

  # определение загрузочного диска
  boot_disk {
    initialize_params {
      image = "${var.app_disk_image}"
    }
  }

  # определение сетевого интерфейса
  network_interface {
    network = "${var.network}"

    access_config {
      nat_ip = "${google_compute_address.app_ip.address}"
    }
  }

  metadata {
    ssh-keys = "${var.ssh_user}:${file("${var.public_key_path}")}"
  }
}

# setup DATABASE_URL from var.mongodb_ip
data "template_file" "puma_service" {
  template = "${file("${path.module}/files/puma.service.tpl")}"

  vars {
    mongodb_ip = "${var.mongodb_ip}"
  }
}

resource "null_resource" "deploy_app" {
  count = "${var.should_deploy_app ? 1 : 0}"

  provisioner "remote-exec" {
    inline = ["sudo gem install bundler"]
  }

  provisioner "file" {
    content     = "${data.template_file.puma_service.rendered}"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "${path.module}/files/deploy.sh"
  }

  connection {
    type        = "ssh"
    host        = "${google_compute_address.app_ip.address}"
    user        = "${var.ssh_user}"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-${var.network}"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["reddit-app"]
}
