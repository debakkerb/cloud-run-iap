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
  project_id                = data.terraform_remote_state.infrastructure_state.outputs.project_id
  project_number            = data.terraform_remote_state.infrastructure_state.outputs.project_number
  region                    = data.terraform_remote_state.infrastructure_state.outputs.region
  full_image_name           = data.terraform_remote_state.infrastructure_state.outputs.full_image_name
  image_tag                 = data.external.git_tag.result.tag
  cloud_run_service_account = data.terraform_remote_state.infrastructure_state.outputs.cloud_run_identity
}

data "external" "git_tag" {
  program = ["bash", "${path.module}/scripts/img-tag.sh"]
}