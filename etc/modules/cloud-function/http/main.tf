module "base" {
  source = "../base"
  bucket = var.bucket
  files  = var.files
  name   = var.name
}

resource "google_cloudfunctions_function" "main" {
  for_each              = var.regions
  region                = each.value
  name                  = var.name
  runtime               = "go111"
  source_archive_bucket = var.bucket
  source_archive_object = module.base.object
  entry_point           = var.entry_point
  available_memory_mb   = var.available_memory_mb
  timeout               = var.timeout_seconds
  service_account_email = var.service_account_email
  environment_variables = var.environment_variables
  vpc_connector         = var.vpc_connector
  max_instances         = var.max_instances
  trigger_http          = true
}

resource "google_cloudfunctions_function_iam_member" "main" {
  for_each       = var.regions
  region         = google_cloudfunctions_function.main[each.value].region
  cloud_function = google_cloudfunctions_function.main[each.value].name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
