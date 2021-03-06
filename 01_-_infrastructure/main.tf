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

locals {
  full_image_name = "${var.region}-docker.pkg.dev/${module.project.project_id}/${google_artifact_registry_repository.default.name}/cr-iap-demo"
  org_policy = var.disable_org_policy_domain_restricted_sharing ? {
    "constraints/iam.allowedPolicyMemberDomains" = {
      inherit_from_parent = null
      suggested_value     = null
      status              = true
      values              = null
    }
  } : {}

  cloud_run_identity_permissions = [
    "roles/compute.viewer"
  ]
}

module "project" {
  source = "./modules/project"

  project_name       = var.project_name
  billing_account_id = var.billing_account_id
  parent             = var.parent
  org_policy_list    = local.org_policy

  project_apis = [
    "run.googleapis.com",
    "cloudbuild.googleapis.com",
    "artifactregistry.googleapis.com",
    "sourcerepo.googleapis.com",
    "iap.googleapis.com",
    "secretmanager.googleapis.com"
  ]
}

resource "google_service_account" "cloud_run_identity" {
  project      = module.project.project_id
  account_id   = "cr-demo-id"
  display_name = "Cloud Run Demo App Identity"
}

resource "google_project_iam_member" "cloud_run_identity_permissions" {
  for_each = toset(local.cloud_run_identity_permissions)
  project  = module.project.project_id
  member   = "serviceAccount:${google_service_account.cloud_run_identity.email}"
  role     = each.value
}

resource "google_artifact_registry_repository" "default" {
  provider = google-beta

  project       = module.project.project_id
  format        = "DOCKER"
  repository_id = var.repository_id
  location      = var.region
  description   = "Artifact registry, managed via Terraform."
}

resource "local_file" "deploy_script" {
  filename = "../02_-_application/app_code/.envrc"

  content = templatefile("${path.module}/templates/.envrc.tpl", {
    PROJECT_ID      = module.project.project_id
    SERVICE_ACCOUNT = google_service_account.cloud_run_identity.email
    REGION          = var.region
    IMAGE_FULL_NAME = local.full_image_name
  })
}