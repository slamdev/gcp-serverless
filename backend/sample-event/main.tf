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
  source        = "../../etc/modules/cloud-function/pubsub"
  name          = "sample-event"
  regions       = var.regions
  bucket        = var.functions_bucket
  topic_trigger = "sample"
  files = [
    "go.mod",
    "function.go",
  ]
}
