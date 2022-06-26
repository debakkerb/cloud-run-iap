#!/usr/bin/env bash

# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "Building Docker image ..."
docker build . --platform linux/amd64 -t ${IMAGE_FULL_NAME}:latest && docker push ${IMAGE_FULL_NAME}:latest

# echo "Deploying application ..."
# gcloud run deploy cr-iap-demo --image ${IMAGE_FULL_NAME}:latest --project ${PROJECT_ID} --service-account ${SERVICE_ACCOUNT} --region ${REGION} --allow-unauthenticated

# echo "Add allUsers to the IAM policy."
# gcloud run services add-iam-policy-binding cr-iap-demo --region ${REGION} --member allUsers --role roles/run.invoker --project ${PROJECT_ID}