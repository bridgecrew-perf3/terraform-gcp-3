data "template_file" "cloud_init" {
  template = file("${path.module}/files/cloud_init.sh")
}
