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

module "project" {
  source = "./modules/project"

  project_name       = var.project_name
  billing_account_id = var.billing_account_id
  parent             = var.parent

  project_apis = [
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com"
  ]
}

resource "google_service_account" "cloud_run_identity" {
  project      = module.project.project_id
  account_id   = "cr-demo-id"
  display_name = "Cloud Run Demo App Identity"
}

resource "google_artifact_registry_repository" "default" {
  provider = google-beta

  project       = module.project.project_id
  format        = "DOCKER"
  repository_id = var.repository_id
  location      = var.region
  description   = "Artifact registry, managed via Terraform."
}

