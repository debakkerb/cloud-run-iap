# Cloud Run Demo


**DISCLAIMER**

**Use this code base at your own risk.  This is a small demo application that showcases some features on Google Cloud.  This is NOT a production ready application and shouldn't be used as such.**

The purpose of this demo is to showcase running a Cloud Run application, protected by Identity Aware Proxy (IAP).  When this protection is enabled, a public HTTPS load balancer will enforce an authenticated session before users can access your application.  

## Installation

The code base is split in two separate folders, as we are running in a chicken and egg kind of problem here.  First, we create the project, enable the necessary APIs, enable Artifact Registry and create a service account for the demo application.  In an enterprise world, it may be that this part is created by a centralised team that takes care of offering shared services to other business units.  This will also generate a build file to build the Docker image and push it to the Artifact Registry repository.  This saves a bit of copy/paste work, as names can get quite long.

The second layer contains both the sample code and the infrastructure code to create the Cloud Run service.  There is still a manual step to be executed as well, which cannot be done through APIs at the moment, unfortunately.

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

This should create the necessare Google Cloud infrastructure and a shell script that can be used to build and deploy the Docker image.  Of course, there is nothing stopping you from either deploying directly from the Git repository and/or using build packs instead of manually writing your Dockerfile. 

### Application

Firstly, you need to push the container image that contains your application code, before you can create the infrastructure for the application (Cloud Run service and the HTTPS load balancer).

```shell
# Generate the container image
cd ../02_-_application/app_code
./deploy.sh

# Create the infrastructure
cd ../infra

# Create terraform.tfvars file, with the necessary variables. Replace the temp variables with the actual variables.
cat <<EOT >> terraform.tfvars
domain = "test.domain.com
EOT

terraform init -reconfigure -upgrade
terraform apply -auto-approve
```

It will take a while to expose the domain on the SSL certificate that is exposed for the domain that was provided in the previous step.  It can take up to an hour before the SSL certificate is provisioned, so until then you will receive errors in Chrome related to an incorrect SSL certificate being provided.  You can check the status of the SSL certificate by running the following command (`jq` has to be installed):

```shell
$(terraform show -json | jq -r .values.outputs.check_ssl_cert_status.value)
```

Additionally, you also have to update the DNS records on your domain, to link the subdomain, as configured in the `domain`-variable, to the external IP address of the Load Balancer.

### Add IAP Protection
Unfortunately, the next steps can't be completed through IaC.  Please follow the instructions listed [here](https://cloud.google.com/iap/docs/enabling-cloud-run#console) to complete IAP protection. 
