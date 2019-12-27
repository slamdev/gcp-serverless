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

variable "functions_bucket" {
  type = string
}

variable "locations" {
  type = list(string)
}

variable "service_account_roles" {
  type = set(string)
  default = [
    "roles/storage.admin",
  ]
}

resource "google_storage_bucket" "main" {
  name          = var.functions_bucket
  location      = var.locations[0]
  force_destroy = true
}

resource "google_project_iam_member" "main" {
  for_each = var.service_account_roles
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}
