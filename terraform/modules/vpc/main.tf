resource "google_compute_firewall" "firewall_ssh" {
  name        = "${var.network}-allow-ssh"
  description = "Allow SSH from ip ranges"
  network     = "${var.network}"
  priority    = 65534

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = "${var.source_ranges}"
}
