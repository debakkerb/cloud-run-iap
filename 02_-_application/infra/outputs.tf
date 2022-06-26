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

output "service_url" {
  value = google_cloud_run_service.cr_iap_demo.status[0].url
}

output "load_balancer_address" {
  value = google_compute_global_address.external_lb_address.address
}

output "check_ssl_cert_status" {
  value = "gcloud compute ssl-certificates describe ${google_compute_managed_ssl_certificate.external_lb_managed_ssl_cert.name} --project ${local.project_id}"
}