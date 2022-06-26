/**
 * Copyright 2022 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "google_compute_global_address" "external_lb_address" {
  project      = local.project_id
  name         = "cr-iap-lb-address"
  ip_version   = "IPV4"
  description  = "IP address for the Load Balancer."
  address_type = "EXTERNAL"
}

resource "google_compute_managed_ssl_certificate" "external_lb_managed_ssl_cert" {
  project     = local.project_id
  name        = "lb-managed-cert"
  description = "SSL certificate for the Cloud Run service."

  managed {
    domains = [var.domain]
  }
}

resource "google_compute_region_network_endpoint_group" "external_lb_neg" {
  project               = local.project_id
  name                  = "lb-managed-neg"
  region                = local.region
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.cr_iap_demo.name
  }
}

resource "google_compute_backend_service" "backend_service" {
  project     = local.project_id
  name        = "lb-managed-backend"
  protocol    = "HTTP"
  port_name   = "http"
  timeout_sec = 30
  backend {
    group = google_compute_region_network_endpoint_group.external_lb_neg.id
  }
}

resource "google_compute_url_map" "lb_url_map" {
  project         = local.project_id
  name            = "lb-managed-url-map"
  default_service = google_compute_backend_service.backend_service.id
}

resource "google_compute_target_https_proxy" "lb_target_proxy" {
  project          = local.project_id
  name             = "lb-target-proxy"
  ssl_certificates = [google_compute_managed_ssl_certificate.external_lb_managed_ssl_cert.id]
  url_map          = google_compute_url_map.lb_url_map.id
}

resource "google_compute_global_forwarding_rule" "lb_fwd_rule" {
  project    = local.project_id
  name       = "lb-fwd-rule"
  target     = google_compute_target_https_proxy.lb_target_proxy.id
  port_range = "443"
  ip_address = google_compute_global_address.external_lb_address.address
}

resource "google_compute_url_map" "https_redirect" {
  project = local.project_id
  name    = "lb-https-redirect"

  default_url_redirect {
    strip_query            = false
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    https_redirect         = true
  }
}

resource "google_compute_target_http_proxy" "https_redirect" {
  project = local.project_id
  name    = "lb-https-redirect"
  url_map = google_compute_url_map.https_redirect.id
}

resource "google_compute_global_forwarding_rule" "https_redirect" {
  project    = local.project_id
  name       = "lb-https-redirect"
  target     = google_compute_target_http_proxy.https_redirect.id
  port_range = "80"
  ip_address = google_compute_global_address.external_lb_address.address
}