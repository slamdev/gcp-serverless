terraform {
  backend "gcs" {}
}

provider "google" {
  version = "3.3.0"
  project = var.project_id
}

provider "archive" {
  version = "1.3.0"
}

variable "project_id" {
  type = string
}

variable "regions" {
  type = set(string)
}

variable "functions_bucket" {
  type = string
}

module "cloud-function" {
  source       = "../../etc/modules/cloud-function/firestore"
  name         = "sample-db"
  regions      = var.regions
  bucket       = var.functions_bucket
  project_id   = var.project_id
  path_trigger = "users/{username}"
  on_create    = true
  files = [
    "go.mod",
    "function.go",
  ]
}
