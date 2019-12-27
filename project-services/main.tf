terraform {
  backend "gcs" {}
}

provider "google" {
  version = "3.3.0"
  project = var.project_id
}

variable "project_id" {
  type = string
}

variable "services" {
  type = set(string)
  default = [
    "cloudfunctions.googleapis.com",
    "dns.googleapis.com",
    "compute.googleapis.com",
  ]
}

resource "google_project_service" "main" {
  for_each                   = var.services
  project                    = var.project_id
  service                    = each.value
  disable_on_destroy         = false
  disable_dependent_services = false
}
