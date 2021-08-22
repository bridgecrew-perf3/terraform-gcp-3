resource "google_compute_instance" "vm_instance" {
  name         = "${var.gcp_project_id}-instance"
  machine_type = "e2-micro"
  allow_stopping_for_update = true

  tags = [ "ssh" ]

  metadata = {
    "ssh-keys" = join("\n", [for key in var.ssh_keys : "${key.user}:${file(key.filepath)}"])
  }

  metadata_startup_script = data.template_file.cloud_init.rendered

  boot_disk {
    auto_delete = true
    initialize_params {
      image = "ubuntu-2004-focal-v20210720"
      size = 30
      type = "pd-standard"
    }
  }

  network_interface {
    subnetwork = var.public_subnet_self_link
    access_config {
    }
  }
}