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
  name     = var.service_name

  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = local.cloud_run_service_account
      containers {
        image = "${local.full_image_name}:${local.image_tag}"
        env {
          name = "CLIENT_ID"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.iap_secret_manager_client_id.secret_id
              key  = "latest"
            }
          }
        }
        env {
          name = "CLIENT_SECRET"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.iap_secret_manager_client_secret.secret_id
              key  = "latest"
            }
          }
        }
      }
    }
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
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

resource "google_iap_web_iam_member" "cloud_run_access" {
  for_each = var.cloud_run_service_access
  project  = local.project_id
  member   = each.value
  role     = "roles/iap.httpsResourceAccessor"
}

resource "google_secret_manager_secret" "iap_secret_manager_client_secret" {
  project   = local.project_id
  secret_id = var.iap_secret_manager_secret_id
  replication {
    user_managed {
      replicas {
        location = local.region
      }
    }
  }
}

resource "google_secret_manager_secret" "iap_secret_manager_client_id" {
  project   = local.project_id
  secret_id = var.iap_secret_manager_client_id
  replication {
    user_managed {
      replicas {
        location = local.region
      }
    }
  }
}

resource "google_secret_manager_secret_iam_member" "cr_secret_manager_client_secret_access" {
  project   = local.project_id
  member    = "serviceAccount:${local.cloud_run_service_account}"
  role      = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.iap_secret_manager_client_secret.id
}

resource "google_secret_manager_secret_iam_member" "cr_secret_manager_client_id_access" {
  project   = local.project_id
  member    = "serviceAccount:${local.cloud_run_service_account}"
  role      = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.iap_secret_manager_client_id.id
}

resource "google_secret_manager_secret_version" "iap_client_secret" {
  secret      = google_secret_manager_secret.iap_secret_manager_client_secret.id
  secret_data = google_iap_client.project_oauth_client.secret
}

resource "google_secret_manager_secret_version" "iap_client_id" {
  secret      = google_secret_manager_secret.iap_secret_manager_client_id.id
  secret_data = google_iap_client.project_oauth_client.client_id
}
