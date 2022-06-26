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

resource "google_cloud_run_service" "cr_iap_demo" {
  project  = local.project_id
  location = local.region
  name     = "cr-iap-demo"

  template {
    spec {
      service_account_name = local.cloud_run_service_account
      containers {
        image = local.full_image_name
      }
    }
  }
}

data "google_iam_policy" "allow_no_auth" {
  binding {
    members = ["allUsers"]
    role    = "roles/run.invoker"
  }
}

resource "google_cloud_run_service_iam_policy" "allow_no_auth_policy" {
  project     = local.project_id
  location    = local.region
  policy_data = data.google_iam_policy.allow_no_auth.policy_data
  service     = google_cloud_run_service.cr_iap_demo.name
}