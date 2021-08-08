variable "gcp_project_id" {
  type = string
  default = "goofing"
}

variable "gcp_region" {
  type = string
  default = "us-central1"
}

variable "gcp_region_zone" {
  type = string
  default = "us-central1-c"
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_region_zone
  user_project_override = true
  credentials = "${dirname(path.module)}/private_files/gcp_key.json"
  version = "3.65"
}

resource "google_compute_project_metadata" "ssh_keys" {
  project = var.gcp_project_id
  metadata = {
    ssh-keys = <<EOF
      ubuntu:${file("${dirname(path.module)}/private_files/ssh_client.pub")}
    EOF
  }
}

resource "google_compute_network" "vpc_network" {
  project = var.gcp_project_id
  name                    = "${var.gcp_project_id}-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnetwork" {
  name = "${var.gcp_project_id}-subnetwork"
  ip_cidr_range = "10.2.0.0/16"
  region = var.gcp_region
  network = google_compute_network.vpc_network.self_link
}

resource "google_compute_firewall" "public_firewall" {
  name    = "${var.gcp_project_id}-allow-ssh"
  network = google_compute_network.vpc_network.self_link
  direction = "INGRESS"
  source_ranges = [ "0.0.0.0/0" ]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.gcp_project_id}-instance"
  machine_type = "e2-micro"
  allow_stopping_for_update = true

  tags = [ "ssh" ]

  metadata = {
    "ssh-keys" = "ubuntu:${file("${dirname(path.module)}/private_files/ssh_client.pub")}"
  }

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-2004-focal-v20210720"
      size = 30
      type = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.public_subnetwork.self_link
    access_config {
    }
  }

  depends_on = [
    google_compute_project_metadata.ssh_keys
  ]
}
