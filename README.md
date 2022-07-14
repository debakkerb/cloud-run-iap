# Cloud Run Demo

**DISCLAIMER**

**Use this code base at your own risk.  This is a small demo application that showcases some features on Google Cloud.  This is NOT a production ready application and shouldn't be used as such.**

The purpose of this demo is to showcase running a Cloud Run application, protected by Identity Aware Proxy (IAP).  When this protection is enabled, a public HTTPS load balancer will enforce an authenticated session before users can access your application.  

## Table of Content
* [Installation](#installation)
* [Remove all resources](#destroy)
* [Development](#development)
* [Custom Image](#custom-image)
* [Application Updates](#application-updates)

## Installation

The code base is split in two separate folders, as we are running in a chicken and egg kind of problem here.  First, we create the project, enable the necessary APIs, enable and create an Artifact Registry repository and create a service account for the demo application.  In an enterprise world, it may be that this part is created by a centralised team that takes care of offering shared services to other business units.  This will also generate a build file to build the Docker image and push it to the Artifact Registry repository.  This saves a bit of copy/paste work, as names can get quite long.

The second layer contains both the sample code and the infrastructure code to create the Cloud Run service. 

### Prerequisites
To build and push the image to Artifact Registry, make sure that you have a local installation of Docker running and that you authenticate the local Docker runner, so it can use your `gcloud`-credentials to talk to Artifact Registry.

You can find more information [here](https://cloud.google.com/artifact-registry/docs/docker/store-docker-container-images#auth).   

### Base infrastructure

The [Infrastructure](./01_-_infrastructure) folder contains the code to create the following resources:
- Google Cloud Project
- Enable necessary APIs
- Artifact Registry
- Service account for the Cloud Run application


```shell
# Enter the correct directory
cd 01_-_infrastructure

# Create terraform.tfvars file, with the necessary variables. Replace the temp variables with the actual variables.
cat <<EOT >> terraform.tfvars
billing_account_id = "ABCD-ABCD-ABCD-ABCD"
parent = "folders/123456789"
EOT

# Initialize Terraform configuration
terraform init -reconfigure -upgrade

# Apply the configuration
terraform apply -auto-approve
```

**NOTE**

If your Google Cloud organization has the organization policy enabled to restrict domain sharing, set `disable_org_policy_domain_restricted_sharing`.  This will disable that organization policy.  Unfortunately it's required to grant the Invoker role to `allUsers`, as requests are coming in from the Load Balancer, as opposed to coming in directly from individual users.  IAP will take care of authenticating and authorizing individual requests.

This should create the necessary Google Cloud infrastructure and a shell script that can be used to build and deploy the Docker image.  Of course, there is nothing stopping you from either deploying directly from the Git repository and/or using build packs instead of manually writing your Dockerfile. 

### Application

Firstly, you need to push the container image that contains your application code, before you can create the infrastructure for the application (Cloud Run service and the HTTPS load balancer).

```shell
# Generate the container image
make build/image

# Create the infrastructure
cd ../infra

# Create terraform.tfvars file, with the necessary variables. Replace the temp variables with the actual variables.
cat <<EOT >> terraform.tfvars
domain = "test.domain.com"
brand_support_email = "EMAIL"
cloud_run_service_access = ["user:EMAIL"]
EOT

# Apply the Terraform code
terraform init -reconfigure -upgrade
terraform apply -auto-approve
```

Make sure to update `brand_support_email` so it points to an official and functioning email address. Also, update `cloud_run_service_access` with a list of users or groups that should be able to access the service via IAP.  The variable accepts a list, so you can pass in as many groups and/or users as you want, as long as they respect the format `user:` or `group:`. 

It will take a while to expose the domain on the SSL certificate that is exposed for the domain that was provided in the previous step.  It can take up to an hour before the SSL certificate is provisioned, so until then you will receive errors in Chrome related to an incorrect SSL certificate being provided.  You can check the status of the SSL certificate by running the following command (`jq` has to be installed):

```shell
$(terraform show -json | jq -r .values.outputs.check_ssl_cert_status.value)
```

Additionally, you also have to update the DNS records on your domain, to link the subdomain, as configured in the `domain`-variable, to the external IP address of the Load Balancer.  You can do this by adding an A-record on your DNS domain and point it to the external IP address that was created by the Terraform code.  You can get the value by running the following command:
```shell
terraform show -json | jq -r .values.outputs.load_balancer_address.value
```

## Destroy 

To destroy the environment, run `terraform destroy -auto-approve` in [02_-_application/infra](./02_-_application/infra) and [01_-_infrastructure](./01_-_infrastructure).  They commands should be run in this order.

## Custom Image
If the user wants to deploy a custom image, as opposed to the one created in [02_-_application/app_code](./02_-_application/app_code), this can be achieved by setting a the fully qualified image name, incl. tag in the variable `custom_image_name`.  If the image repository is hosted in a different project, make sure that the service account has access to it. 

## Application Updates

As mentioned in the introduction, this is not a production grade application, nor does it contain any best practices to deploy in a safe environment.  If you are developing from your local machine, there is a target in the `Makefile` that you can use to build new images after each update.  In [02_-_application/app_code](02_-_application/app_code), run `make build/devimage`, which will take the current timestamp as the image tag.  This can be used to deploy the application to Cloud Run, by running `terraform apply -auto-approve -var="image_tag=TIMESTAMP"` in [02_-_application/infra](02_-_application/infra).  You will have to copy and paste the timestamp from the output of `make build/devimage`.  