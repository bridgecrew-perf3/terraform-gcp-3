provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
  zone    = var.gcp_region_zone
  user_project_override = true
  credentials = "${dirname(path.module)}/private_files/gcp_key.json"
  version = "3.65"
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

module "gcp_free_instance" {
  source = "../../modules/compute_instance"
  gcp_project_id = var.gcp_project_id
  ssh_keys=[
    {
      user = "ubuntu"
      filepath = "${dirname(path.module)}/private_files/ssh_client.pub"
    }
  ]
  public_subnet_self_link = google_compute_subnetwork.public_subnetwork.self_link
}
