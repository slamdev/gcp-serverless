data "archive_file" "main" {
  type        = "zip"
  output_path = "${path.root}/.terraform/${var.name}.zip"
  dynamic "source" {
    for_each = var.files
    content {
      filename = source.value
      content  = file(source.value)
    }
  }
}

resource "google_storage_bucket_object" "main" {
  name                = "${var.name}-${data.archive_file.main.output_md5}.zip"
  source              = data.archive_file.main.output_path
  bucket              = var.bucket
  content_disposition = "attachment"
  content_encoding    = "gzip"
  content_type        = "application/zip"
}
