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

variable "domain" {
  description = "Domain for the SSL certificate."
  type        = string
}

variable "load_balancer_prefix" {
  description = "Prefix that will be added to all HTTPS LB resources."
  type        = string
  default     = "lb"
}

variable "load_balancer_address_name" {
  description = "Name for the external address of the load balancer."
  type        = string
  default     = "cr-iap-lb-address"
}

variable "load_balancer_managed_cert_name" {
  description = "Name for the managed certificate."
  type        = string
  default     = "cr-iap-ssl-certificate"
}

variable "brand_application_title" {
  description = "Application title linked to the brand of the IAP consent screen."
  type        = string
  default     = "cr-iap-demo"
}

variable "brand_support_email" {
  description = "Supprt email address for the IAP consent screen"
  type        = string
}

variable "iap_client_display_name" {
  description = "Display name for the IAP client consent screen."
  type        = string
  default     = "Cloud Run IAP Demo"
}

variable "cloud_run_service_access" {
  description = "List of identities that can access the Cloud Run service. Should be prefixed with the type (user:, serviceAccount:, group:)"
  type        = set(string)
  default     = []
}