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

# setup bindIp
data "template_file" "mongod_conf" {
  template = "${file("${path.module}/files/mongod.conf.tpl")}"

  vars {
    bind_ip = "127.0.0.1,${google_compute_instance.db.network_interface.0.address}"
  }
}

resource "null_resource" "configure_mongodb" {
  provisioner "file" {
    # source      = "${path.module}/files/mongod.conf.tpl"
    content     = "${data.template_file.mongod_conf.rendered}"
    destination = "/tmp/mongod.conf"
  }

  # provisioner "remote-exec" {
  #   inline = ["sudo sed -i 's/$${bind_ip}/127.0.0.1,${google_compute_instance.db.network_interface.0.address}/g' /etc/mongod.conf && sudo systemctl restart mongod"]
  # }

  provisioner "remote-exec" {
    inline = [
      "sudo mv /tmp/mongod.conf /etc/mongod.conf",
      "sudo systemctl restart mongod",
    ]
  }
  connection {
    type        = "ssh"
    host        = "${google_compute_instance.db.network_interface.0.access_config.0.assigned_nat_ip}"
    user        = "${var.ssh_user}"
    agent       = false
    private_key = "${file("${var.private_key_path}")}"
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
