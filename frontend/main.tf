terraform {
  backend "gcs" {}
}

provider "google" {
  version = "3.3.0"
  project = var.project_id
}

provider "null" {
  version = "2.1.2"
}

provider "archive" {
  version = "1.3.0"
}

variable "project_id" {
  type = string
}

variable "application" {
  type = string
}

variable "locations" {
  type = set(string)
}

variable "domain" {
  type = string
}

locals {
  srcDir = "src"
}

resource "google_storage_bucket" "main" {
  for_each      = var.locations
  //noinspection HILUnknownResourceType
  name          = "${lower(each.value)}.${var.domain}"
  location      = each.value
  force_destroy = true
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_member" "main" {
  for_each = var.locations
  bucket   = google_storage_bucket.main[each.value].name
  role     = "roles/storage.objectViewer"
  member   = "allUsers"
}

data "archive_file" "main" {
  type        = "zip"
  output_path = "${path.root}/.terraform/frontend.zip"
  source_dir  = local.srcDir
}

resource "null_resource" "main" {
  for_each = var.locations
  triggers = {
    src_md5 = data.archive_file.main.output_md5
  }
  depends_on = [
    google_storage_bucket.main,
  ]
  provisioner "local-exec" {
    //noinspection HILUnknownResourceType
    command = "gsutil rsync -J -d -r src gs://${google_storage_bucket.main[each.value].name}"
  }
}
