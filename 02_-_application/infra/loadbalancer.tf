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

#
#resource "google_compute_global_address" "external_lb_address" {
#  project      = module.project.project_id
#  name         = "cr-iap-lb-address"
#  ip_version   = "IPV4"
#  description  = "IP address for the Load Balancer."
#  address_type = "EXTERNAL"
#}
#
#resource "google_compute_managed_ssl_certificate" "external_lb_managed_ssl_cert" {
#  project     = module.project.project_id
#  name        = "lb-managed-cert"
#  description = "SSL certificate for the Cloud Run service."
#
#  managed {
#    domains = [var.domain]
#  }
#}
#
#resource "google_compute_region_network_endpoint_group" "cr_iap_demo_neg" {
#  project               = module.project.project_id
#  name                  = "cr-iap-neg"
#  region                = var.region
#  network_endpoint_type = "SERVERLESS"
#
#  cloud_run {
#    service = "cr-iap-demo"
#  }
#}
#
#resource "google_compute_region_backend_service" "backends" {
#  project     = module.project.project_id
#  name        = "cr-iap-demo-backend"
#  protocol    = "HTTP"
#  port_name   = "http"
#  timeout_sec = 30
#
#  backend {
#    group = google_compute_region_network_endpoint_group.cr_iap_demo_neg.id
#  }
#}
#
#resource "google_compute_region_url_map" "cr_iap_url_map" {
#  project         = module.project.project_id
#  name            = "cr-iap-demo-url-map"
#  region          = var.region
#  default_service = google_compute_region_backend_service.backends.id
#}
#
#resource "google_compute_region_target_https_proxy" "cr_iap_demo_target_proxy" {
#  project          = module.project.project_id
#  name             = "cr-iap-demo-proxy"
#  ssl_certificates = [google_compute_managed_ssl_certificate.external_lb_managed_ssl_cert.id]
#  url_map          = google_compute_region_url_map.cr_iap_url_map.id
#}
#
#resource "google_compute_global_forwarding_rule" "cr_iap_demo_fwd_rule" {
#  project    = module.project.project_id
#  name       = "cr-iap-demo-fwd-rule"
#  target     = google_compute_region_target_https_proxy.cr_iap_demo_target_proxy.id
#  port_range = "443"
#  ip_address = google_compute_global_address.external_lb_address.address
#}
#
#output "lb_address" {
#  value = google_compute_global_address.external_lb_address.address
#}