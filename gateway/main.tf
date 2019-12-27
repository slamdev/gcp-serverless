terraform {
  backend "gcs" {}
}

provider "google" {
  version = "3.3.0"
  project = var.project_id
}

provider "google-beta" {
  version = "3.3.0"
  project = var.project_id
}

variable "project_id" {
  type = string
}

variable "regions" {
  type = set(string)
}

variable "locations" {
  type = set(string)
}

variable "domain" {
  type = string
}

data "google_compute_image" "main" {
  family  = "ubuntu-minimal-1804-lts"
  project = "ubuntu-os-cloud"
}

data "template_file" "envoy_config" {
  for_each = var.regions
  template = file("envoy.yaml")
  vars = {
    //noinspection HILUnknownResourceType
    function_host = "${each.value}-${var.project_id}.cloudfunctions.net"
    bucket_host = [
      for l in var.locations :
      "${lower(l)}.${var.domain}"
      if length(regexall("${lower(l)}.*", each.value)) > 0
    ][0]
  }
}

data "template_file" "cloud_config" {
  for_each = var.regions
  template = file("cloud-config.yaml")
  vars = {
    envoy_config = indent(6, data.template_file.envoy_config[each.value].rendered)
  }
}

resource "google_compute_instance_template" "main" {
  for_each = var.regions
  //noinspection HILUnknownResourceType
  name_prefix  = "gateway-${each.value}-"
  machine_type = "f1-micro"
  region       = each.value
  disk {
    source_image = data.google_compute_image.main.self_link
    auto_delete  = true
    boot         = true
  }
  lifecycle {
    create_before_destroy = true
  }
  service_account {
    email = "${var.project_id}@appspot.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
  scheduling {
    preemptible         = true
    automatic_restart   = false
    on_host_maintenance = "TERMINATE"
  }
  network_interface {
    network = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }
  tags = [
    "gateway",
  ]
  metadata = {
    user-data = data.template_file.cloud_config[each.value].rendered
  }
}

//noinspection MissingProperty
resource "google_compute_region_instance_group_manager" "main" {
  for_each = var.regions
  //noinspection HILUnknownResourceType
  name = "gateway-${each.value}"
  //noinspection HILUnknownResourceType
  base_instance_name = "gateway-${each.value}"
  version {
    name              = google_compute_instance_template.main[each.value].self_link
    instance_template = google_compute_instance_template.main[each.value].self_link
  }
  region      = each.value
  target_size = 2
  named_port {
    name = "http"
    port = 80
  }
  named_port {
    name = "admin"
    port = 9901
  }
  //noinspection HCLUnknownBlockType
  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 5
    max_unavailable_fixed        = 0
    min_ready_sec                = 30
  }
  auto_healing_policies {
    health_check      = google_compute_health_check.main.self_link
    initial_delay_sec = 1
  }
}

resource "google_compute_health_check" "main" {
  name                = "gateway"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 10
  http_health_check {
    request_path = "/ready"
    port         = "9901"
  }
}

resource "google_compute_backend_service" "main" {
  name             = "gateway"
  protocol         = "HTTP"
  port_name        = "http"
  timeout_sec      = 10
  session_affinity = "NONE"
  health_checks = [
    google_compute_health_check.main.self_link,
  ]
  dynamic "backend" {
    for_each = var.regions
    content {
      group = google_compute_region_instance_group_manager.main[backend.value].instance_group
    }
  }
}

resource "google_compute_firewall" "health_check" {
  name        = "gateway-health-check"
  network     = "default"
  description = "allow Google health checks and network load balancers access"
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports = [
      9901,
    ]
  }
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
    "209.85.152.0/22",
    "209.85.204.0/22",
  ]
  target_tags = [
    "gateway",
  ]
}

resource "google_compute_firewall" "ingress" {
  name    = "gateway-ingress"
  network = "default"
  allow {
    protocol = "tcp"
    ports = [
      "80",
      "443",
    ]
  }
  target_tags = [
    "gateway",
  ]
}

resource "google_compute_url_map" "main" {
  name            = "gateway"
  default_service = google_compute_backend_service.main.self_link
}

resource "google_compute_target_http_proxy" "main" {
  name    = "gateway-http"
  url_map = google_compute_url_map.main.self_link
}

resource "google_compute_managed_ssl_certificate" "main" {
  provider = google-beta
  name     = "gateway"
  //noinspection HCLUnknownBlockType
  managed {
    domains = ["${var.domain}."]
  }
}

resource "google_compute_target_https_proxy" "main" {
  name             = "gateway-https"
  url_map          = google_compute_url_map.main.self_link
  //noinspection HILUnresolvedReference
  ssl_certificates = [google_compute_managed_ssl_certificate.main.self_link]
}

resource "google_compute_global_address" "main" {
  name = "gateway"
}

resource "google_compute_global_forwarding_rule" "main_http" {
  name       = "gateway-http"
  target     = google_compute_target_http_proxy.main.self_link
  ip_address = google_compute_global_address.main.address
  port_range = 80
}

resource "google_compute_global_forwarding_rule" "main_https" {
  name       = "gateway-https"
  target     = google_compute_target_https_proxy.main.self_link
  ip_address = google_compute_global_address.main.address
  port_range = 443
}

resource "google_dns_managed_zone" "main" {
  name     = "main"
  dns_name = "${var.domain}."
}

resource "google_dns_record_set" "main" {
  name         = google_dns_managed_zone.main.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    google_compute_global_address.main.address,
  ]
}

resource "google_dns_record_set" "frontend" {
  for_each = var.locations
  //noinspection HILUnknownResourceType
  name         = "${each.value}.${google_dns_managed_zone.main.dns_name}"
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.main.name
  rrdatas = [
    "c.storage.googleapis.com.",
  ]
}
