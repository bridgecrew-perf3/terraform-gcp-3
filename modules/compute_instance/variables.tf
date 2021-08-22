variable "gcp_project_id" {
  type = string
  description = "ID of the gcp project to use"
}

variable "ssh_keys" {
  type = list(object({
    user = string
    filepath = string
  }))
  description = "list of public ssh keys that have access to the VM"
}

variable "public_subnet_self_link" {
  type = string
  description = "GCP URI to the public subnet for the instance"
}
