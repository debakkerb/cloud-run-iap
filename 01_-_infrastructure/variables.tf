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

variable "billing_account_id" {
  description = "Billing account that should be assigned to the project."
  type        = string
}

variable "parent" {
  description = "Parent of the project, should be set in the form of organizations/ORG_ID or folders/FOLDER_ID"
  type        = string
}

variable "project_name" {
  description = "Name for the project."
  type        = string
  default     = "cloud-run-demo"
}

variable "region" {
  description = "Default region for all resources."
  type        = string
  default     = "europe-west1"
}

variable "repository_id" {
  description = "ID of the Artifact Registry repository."
  type        = string
  default     = "cloud-run-demo"
}

variable "zone" {
  description = "Default zone for all resources."
  type        = string
  default     = "europe-west1-b"
}

variable "disable_org_policy_domain_restricted_sharing" {
  description = "If the org policy for domain restricted sharing is enforced, disable it for this project.  Cloud Run requires the Invoker role to be assigned to allUsers, as all requests are coming in from the HTTPS Load Balancer."
  type        = bool
  default     = false
}

