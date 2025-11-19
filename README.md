# EPAM AI/Run™ for AWS Migration and Modernization Deployment Guide

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

# Introduction

**EPAM AI/Run™ or AWS Migration and Modernization** is an event-driven, cloud-native SDLC and cloud modernization methodology powered by an integrated
agentic AI automation platform. Delivered as an AWS-native package, it provides seamless third-party integrations with
leading industry solutions, along with proprietary advanced code modernization capabilities. The platform accelerates
workflows, simplifies project onboarding, and enhances productivity across diverse SDLC roles through smart assistance
and full automation. With tailored solutions for migrating legacy systems, databases, and virtual machines to AWS
environments, EPAM AI/Run™ or AWS  ensures alignment with AWS Well-Architected Framework best practices for scalable
and production-ready configurations.

There are no specific region limitations imposed by the product itself. However, since the product is built on AWS
infrastructure, including services like EKS, S3, RDS, EC2, DynamoDB, KMS, ECR, Route53, ACM, and others, it is
recommended to verify whether all the AWS services depicted in the diagram below are supported in your region before
installation [here](https://aws.amazon.com/about-aws/global-infrastructure/regional-product-services/).

Additionally, as the product integrates with AWS Bedrock (including LLMs), it is advisable to ensure that at least one
foundational model for text, image, or video processing, and one model for embedding modality are available in your
region. You can verify supported models [here](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-supported.html).

Since the product is a platform that relies on a variety of AWS services, some of which may take up to 30 minutes to
provision resources (such as ACM), the estimated time for a complete end-to-end installation can range from 1 to 3 hours.

## Table of Contents
1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [EPAM AI/Run™ for AWS Migration and Modernization Architecture](#3-epam-airun-for-aws-migration-and-modernization-deployment-architecture)
4. [AWS Infrastructure Deployment](#4-aws-infrastructure-deployment)
5. [AI Models Integration and Configuration](#5-ai-models-integration-and-configuration)
6. [EPAM AI/Run™ for AWS Migration and Modernization Components Deployment](#6-epam-airun-for-aws-migration-and-modernization-components-deployment)
7. [Application Access](#7-provide-access-to-the-application)
8. [Post Instalaltion Configuration](#8-epam-airun-for-aws-migration-and-modernization-post-installation-configuration)
9. [Cost Management](9#-cost-management)
10. [Monitoring and Recovery](#10-monitoring-and-recovery)
11. [Maintenance](#11-maintenance)

# 1. Overview

This guide provides step-by-step instructions for deploying the EPAM AI/Run™ for AWS Migration and Modernization
application to Amazon EKS and related AWS services. By following these instructions, you will:

* Get along with EPAM AI/Run™ for AWS Migration and Modernization architecture.
* Deploy AWS infrastructure using Terraform.
* Configure and deploy all EPAM AI/Run™ for AWS Migration and Modernization application components by installing Helm Charts.
* Integrate and configure Bedrock LLMs.

Additionally, the EPAM AI/Run™ for AWS application supports the installation of supplementary applications that integrate with our system, such as AI TestMate.
AI TestMate is an autonomous GenAI solution for automatic unit test generation, acting as a "virtual teammate" within the software development lifecycle (SDLC).
It analyzes repositories, creates, and commits tests without manual intervention, helping to quickly increase test coverage and reduce team effort.
The solution leverages an ensemble of large language models (LLMs), an agentic approach, and a secure proxy access layer to the models.
The installation guide you can for the application you can find by path: ```deployment/add-ons/aitestmate/helm-scripts/README.md```


[![Walkthrough Deployment Guide](assets/Deployment_Guide.jpg)](https://youtu.be/MelxbnkoWHo)

## 1.1. How to Use This Guide

For successful deployment, please follow these steps in sequence:
1. First, verify all prerequisites and set up your AWS environment accordingly. Next, deploy the required infrastructure using Terraform.
2. Finally, deploy and configure the  EPAM AI/Run™ for AWS Migration and Modernization components on EKS cluster by installing Helm Charts.
3. Complete post-installation configuration.

Each installation step is designed to ensure a smooth deployment process. The guide is structured to walk you through
from initial setup to a fully functional EPAM AI/Run™ for AWS Migration and Modernization environment on AWS.

# 2. Prerequisites

Before installing EPAM AI/Run™ for AWS Migration and Modernization, carefully review the prerequisites and requirements.

## 2.1. AWS Account Access Requirements
✓ Active AWS Account with a preferred region for deployment.
✓ User or Role with programmatic access to AWS account with permissions to create and manage IAM Roles and Policy Documents.

> ⚠️
> **Do not use the AWS account root user for any deployment or operations!**

## 2.2. Domain Name
✓ Available wildcard DNS hosted zone in Route53.

EPAM AI/Run™ for AWS Migration and Modernization terraform modules will automatically create:
* DNS Records.
* TLS certificate through AWS Certificate Manager, which will be used later by the ALB and NLB.

## 2.3. External connections
✓ Verify that firewall rules, SG and NACLs of EKS cluster allow outbound access to:
*  EPAM AI/Run™ for AWS Migration and Modernization container registry: **valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems/codemie**.
* 3rd party container registries: quay.io, docker.io, registry.developer.zurich/data.com.
* Any service you're planning to use with EPAM AI/Run™ for AWS Migration and Modernization (for example, GitHub instance).

✓ Firewall on your integration service allow inbound traffic from the EPAM AI/Run™ for AWS Migration and Modernization NAT Gateway public IP address.

ℹ️ NAT Gateway public IP address will be known after EKS installation.

## 2.4. LLM Models
✓ Activated region in AWS where AWS Bedrock Models are available.

✓ Activated desired LLMs and embeddings models in AWS account (for example, Sonnet 3.5/3.7, AWS Titan 2.0).

> ℹ️  EPAM AI/Run™ for AWS Migration and Modernization can be deployed with mock LLM configurations initially. Real configurations can be provided later if client-side approvals require additional time.

> ⚠️ **Important**: EPAM AI/Run™ for AWS Migration and Modernization requires at least one configured chat model and one embedding model to function properly. Ensure these are set up before proceeding with creating assistants or data sources.

> ⚠️ **Important**: After September 29,  2025, models will be automatically enabled for you.

## 2.5. User Permissions and Admission Control Requirements for EKS

<details>
<summary>Please expand to review components and permissions:

✓ Admin EKS permissions with rights to create `namespaces`.

✓ Admission webhook allows creation of Kubernetes resources listed below (applicable when deploying onto an existing EKS cluster with enforced policies).

</summary>

| EPAM AI/Run™ for AWS Migration and Modernization Component | Kubernetes APIs | Description |
|-------------------------------|-----------------|-------------|
| NATS                          | `Service` | NATS messaging system requires a LoadBalancer service type for client-server communication. When running `codemile-plugins`: <br>– within the same VPC as the EKS cluster – internal LoadBalancer configured for secure, private network communication<br>– outside the EKS cluster's VPC – Public LoadBalancer required for cross-network communication |
| keycloak-operator             | `ClusterRole`, `ClusterRoleBinding`, `Role`, `RoleBinding`, `CRDs`, `CR` | Cluster-wide permissions required for managing Keycloak configuration, including realm, clients, and user federation settings |
| Postgres-operator             | `ClusterRole`, `ClusterRoleBinding`, `CRDs`, `CR` | Cluster-wide permissions required for managing PostgreSQL instances and their lifecycle |
| ElasticSearch                 | `Pod[securityContext]` | InitContainer must run as root user to set system parameter `vm.max_map_count=262144` |
| All components                | `Pod[securityContext]` | All components require SecurityContext with `readOnlyRootFilesystem: false` for proper operation |

</details>

## 2.6. Deployer instance requirements
✓ The following software must be pre-installed and configured on the deployer laptop or VDI instance before beginning
the deployment process(if you're using Windows, avoid mixing WSL with a native Windows installation):

<details>
<summary>Please expand to review tools:</summary>

* [terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) `v1.5.7`
* [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)
* [helm](https://helm.sh/docs/intro/install/)  `v3.16.0+`
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [docker](https://docs.docker.com/get-started/get-docker/)
* [natscli](https://github.com/nats-io/natscli?tab=readme-ov-file#installation)
* [nsc](https://github.com/nats-io/nsc)
* [htpasswd](https://httpd.apache.org/)

</details>

ℹ️ If you use Windows, please use linux shells such as Git Bash, WSL, etc

## 2.7. Active Subscription in AWS Marketplace.

Before you start deployment, please ensure that you have an active subscription to the EPAM AI/Run™ for AWS Migration and Modernization in the [AWS Marketplace](https://aws.amazon.com/marketplace/pp?sku=86jeke9oer4t5bdyryfgyya7h).
After subscription activation the links to AWS ECR with required images and helm charts will be visible for you. You need them for deployment. Also, you can choose the version of the product you install.
> **Replace the dummy resource link `valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com` and version `x.y.z` with correct ones in the commands and configuration files where necessary.**

# 3. EPAM AI/Run™ for AWS Migration and Modernization deployment architecture

The diagram below depicts the EPAM AI/Run™ for AWS Migration and Modernization infrastructure deployment in one region (AZ) of the AWS public cloud environment.

<img src="assets/AI_Run_For_AWS.drawio.svg" width="1200" style="background-color: #ffffff;">

<details>
<summary>Expand this section for reviewing EKS cluster components</summary>
Container Resources Requirements

| Component           | Pods | RAM | vCPU |
|---------------------|------|-----|------|
| CodeMie API         | 2 | 8Gi | 4.0 |
| CodeMie UI          | 1 | 128Mi | 0.1 |
| Elasticsearch       | 2 | 16Gi | 4.0 |
| Kibana              | 1 | 1Gi | 1.0 |
| Mermaid-server      | 1 | 512Mi | 1.0 |
| PostgreSQL*         | 1 | 1Gi | 0.2 |
| Keycloak + DB       | 1 + 1 | 4Gi | 2.0 |
| Oauth2-proxy        | 1 | 128Mi | 0.1 |
| NATS + Auth Callout | 1 + 1 | 512Mi | 1.0 |
| MCP Connect         | 1 | 1Gi | 0.5 |
| Fluentbit           | daemonset | 128Mi | 0.1 |

*The database by default is AWS RDS, but there is an option to deploy it as EKS cluster component.
</details>

# 4. AWS Infrastructure Deployment
## 4.1. Overview

Skip if you have ready EKS cluster with all required services (check the diagram above).
This section describes the process of deploying the EPAM AI/Run™ for AWS Migration and Modernization infrastructure within an AWS environment. Terraform is used to manage resources and configure services.

>⚠️ A crucial step involves using a registered domain name added to AWS Route 53, which allows Terraform to automatically create SSL/TLS certificates via AWS Certificate Manager. These certificates are essential for securing traffic handled by the Application Load Balancer (ALB) and Network Load Balancer (NLB).

There are two deployment options available. Use the script if you want an easier deployment flow. Use the manual option if you want to control Terraform resources and provide customization.

## 4.2. Set up Hosted zone

### 4.2.1. Open Hosted zone page

<img src="assets/deployment-guide/Hosted_Zone4_2_1.png">

### 4.2.2. Click on Create hosted zone button

<img src="assets/deployment-guide/Hosted_Zone4_2_2.png">

### 4.2.3. Create new hosted zone.
Create new hosted zone. Domain name should have the following pattern <any_name>.<your_DNS>.
<any_name> can be specific environment, for instance
``` dev.example.com ```

<img src="assets/deployment-guide/Hosted_Zone4_2_3.png">

### 4.2.4. Locate NS servers values
Copy "Value/Route traffic to" value from NS record that was recently created.
Example of the NS record value:
```
ns-111.awsdns-00.net.
ns-121.awsdns-11.org.
ns-123.awsdns-22.com.
ns-1234.awsdns-33.co.uk.
```
<img src="assets/deployment-guide/Hosted_Zone4_2_4.png">

### 4.2.5. Adjust parent Hosted zone
Open parent hosted zone with name which equal to DNS name.
Create a new record in the hosted zone from the previous step
Record name - should be the same value as <any_name> from step 4.2.3 ``` dev.example.com ```
Record type - select "NS" option
Value - Paste the value from step 4.2.4

<img src="assets/deployment-guide/Hosted_Zone4_2_5.png">

## 4.3. Set up credential for AWS

1. Find or create "credentials" file.
> By default, the file is located in the following directory:
    * "/Users/<user_name>/.aws" - Linux/Mac
    * "C:\Users\<profile>\.aws" - Windows

2. Open the file and update next property: aws_region, aws_access_key_id, aws_secret_access_key, aws_session_token (if you use temporary credential)

Also, you can use the command instead previous 2 steps

```bash
  aws configure
```
## 4.4. Clone repository

```bash
  git clone https://github.com/epam/EPAM-AI-RUN-Marketplace.git
  cd EPAM-AI-RUN-Marketplace/deployment/terraform-scripts
 ```

## 4.5. Infrastructure Provisioning

### 4.5.1. Automated: Installation Script

The `terraform.sh` script automates the deployment of infrastructure.

To deploy EPAM AI/Run™ for AWS Migration and Modernization infrastructure to AWS use the following steps:

1. Fill configuration details that specific for your AWS account in `deployment.conf`:
<details>
<summary>Expand this section for configuration details:</summary>

```bash
# AI/Run CodeMie deployment variables configuration
# Fill required values and save this file as deployment.conf

TF_VAR_region="<REGION>" # Example: us-east-1
TF_VAR_subnet_azs='[<SUBNET AZS>]' # Example: '["us-east-1a", "us-east-1b", "us-east-1c"]'

TF_VAR_platform_name="<PLATFORM NAME>" # Example: ai-run
TF_VAR_deployer_role_name="<ROLE>" # Example: AIRunDeployerRole. Ensure this is a new and unique name

TF_VAR_s3_states_bucket_name="<BUCKET NAME>" # Example: ai-run-terraform-states. Ensure this is a new and unique name following S3 naming rules.
TF_VAR_table_name="<TABLE NAME>" # Example: ai-run_terraform_locks. Ensure this is a new and unique name

TF_VAR_platform_domain_name="<DOMAIN NAME>" # Example: example.com.  The value should be taken from the Route 53 hosted zone created in the previous step.

TF_VAR_role_permissions_boundary_arn="" # Example: arn:aws:iam::012345678901:policy/role_boundary. Leave empty if you don't have a permissions boundary or don't want to use one.

# Uncomment in case Eks admin role is differ then current user
#TF_VAR_eks_admin_role_arn=""

# Uncomment in case EBS encryption needed
#TF_VAR_ebs_encrypt="<BOOLEAN VALUE>" # Example: true or false

TF_VAR_spot_instance_types='[{"instance_type":"m6a.2xlarge"}]'
TF_VAR_spot_max_nodes_count=0
TF_VAR_spot_desired_nodes_count=0
TF_VAR_spot_min_nodes_count=0
TF_VAR_demand_instance_types='[{"instance_type":"m6a.2xlarge"}]'
TF_VAR_demand_max_nodes_count=2
TF_VAR_demand_desired_nodes_count=2
TF_VAR_demand_min_nodes_count=1

# RDS
TF_VAR_pg_instance_class="db.c6gd.medium"
```
> ⚠️ **Important**: If you plan to include AI TestMate add-ons, make sure to choose instance_type m6a.2xlarge and configure no fewer than 5-7 nodes.

</details>
2. Run the following command if using a Unix-like operating system:

```bash
  chmod +x terraform.sh
```

3. Run installation script, possible flags:
   * `--access-key ACCESS_KEY`: Use the flag if the `.aws/credentials` file has not been updated.
   * `--secret-key SECRET_KEY`: Use the flag if the `.aws/credentials` file has not been updated.
   * `--region REGION`:         Use the flag if the `.aws/credentials` file has not been updated.
   * `--rds-disable`:           EPAM AI/Run™ for AWS Migration and Modernization by default rely on AWS RDS (Postgres) database. Use this key if you want switch to Postgres Database deployed as a Pod in EKS cluster.
   * `--config-file FILE`:      Load configuration from file (default: deployment.conf)
   * `--help`

   The flags `--access-key`, `--secret-key`, and `--region REGION` can be omitted if step 4.3 has already been completed.


### ⚠️ Warning

EPAM AI/Run™ for AWS Migration and Modernization relies on manged AWS RDS (PostgreSQL) database.
Please consider whether you want to deploy the database as a pod in the EKS cluster or use AWS RDS instead (default behaviour).

This bash script uses the default AWS profile for deploying the infrastructure. Ensure your default profile is properly configured with the necessary credentials and permissions before running the script

To disable AWS RDS and use Postgres as cluster pod, use the `--rds-disable` flag during deployment.

```bash
  bash terraform.sh
```
or
```bash
  ./terraform.sh
```

After execution, the script will:

1. Validate your deployment environment:
   a. Check for required tools (kubectl, AWS CLI, Terraform)
   b. Verify AWS authentication status
   c. Validate configuration parameters
2. Create IAM Deployer role and policy
3. Deploy infrastructure:
   a. Create Terraform backend storage (S3 bucket and DynamoDB table)
   b. Deploy core EPAM AI/Run™ for AWS Migration and Modernization Platform infrastructure
   c. Set up necessary AWS resources
4. Generate Outputs:

   a. The script will create a `deployment_outputs.env` file containing essential infrastructure details:
         ```
         AWS_DEFAULT_REGION=eu-west-2
         EKS_ARN_DEV=arn:aws:eks:eu-west-2:1234xxx:cluster/...
         AWS_SSM_KMS_ID=1294fa78-98ab-cdef-1234-567890abcdef
         AWS_S3_BUCKET_NAME=codemie-platform-bucket
         ```
   b. If the user does not include the `--rds-disable` flag, the `deployment_outputs.env` file will be generated with the relevant infrastructure details:
        ```
        AWS_DEFAULT_REGION=eu-west-2
        ECS_AWS_ROLE_ARN=arn:aws:iam::1234xxx:role/...
        AWS_KMS_KEY_ID=12345678-90ab-cdef-1234-567890abcdef
        AWS_S3_BUCKET_NAME=codemie-platform-bucket
        AWS_RDS_ENDPOINT=database.aaaaaaaaaaa.us-east-1.rds.amazonaws.com
        AWS_RDS_DATABASE_NAME=codemie
        AWS_RDS_DATABASE_USER=dbuser
        AWS_RDS_DATABASE_PASSWORD=SomePassword
       ```

5. Deployment Completion:
   a. A success message will confirm the deployment
   b. Logs will be available in `codemie_aws_deployment_YYYY-MM-DD-HHMMSS.log`
   c. The script will display a summary of deployed resources

⚠️ Keep the `deployment_outputs.env` file secure as it contains sensitive information. Do not commit it to version control.

After successful deployment, you can proceed with the EPAM AI/Run™ for AWS Migration and Modernization components
installation and start using EPAM AI/Run™ for AWS Migration and Modernization services.

⚠️ Important: after successful deployment the dedicated VPC in your AWS account is created in specified region with specified subnets' A-Zs.
VPC contains:
- route tables
- 1 public subnet with attached Internet gateway
- 1 private subnet with attached NAT gateway
- NACLs and SGs created by Terraform modules.
Please consider reviewing its configuration and adjust it according to your security policies.


⚠️ Important: during the deployment several secrets are created in different namespaces for EKS cluster, only users with
proper permissions to EKS cluster can manage them: review, rotate, etc. There is no automated rotation implemented by default,
please consider implementing it after deployment https://aws.amazon.com/blogs/containers/aws-secrets-manager-controller-poc-an-eks-operator-for-automatic-rotation-of-secrets/.

⚠️ Important: The customer manged KMS key **airun-*** is created with key rotation disabled by default. If you want to
enable it, please do it manually after the deployment https://docs.aws.amazon.com/kms/latest/developerguide/rotate-keys.html.

This key is used for encrypt/decrypt operation for several components: secrets, EBS, RDS.
Also, there are AWS KMS manged keys are created for your: ACM, S3.

The recourse policy attached to the keys by default contains only minimal required permissions. If you want to extend,
please do it manually after deployment.

### 4.5.2 Manual Deployment
If the previous step has already been completed, please proceed to skip this step.

<details>
<summary>If you prefer to manually deploy step by step, expand this section for more instructions:</summary>
### 4.6.1. Deployment Order

| # | Resource name |
|---|--------------|
| 1 | IAM deployer role |
| 2 | Terraform Backend |
| 3 | Terraform Platform |

### 4.6.2. IAM `Deployer` Role creation

This step covers the `DeployerRole` AWS IAM role creation.
The role contains minimum necessary permissions to deploy and manage the EPAM AI/Run™ for AWS infrastructure following
the policy of the least privilege access granted.

ℹ️ The created IAM role will be used for all subsequent infrastructure deployments and contains required permissions to manage AWS resources

To create the role, take the following steps:

1. Navigate to codemie-aws-iam folder:
   ```bash
   cd codemie-aws-iam
   ```
2. Review the input variables for Terraform in the `deployment/terraform-scripts/codemie-aws-iam/variables.tf` file and create a `<fileName>.tfvars` in the repo to change default variables values there in a format of key-value. For example:
   ```
   region = "your-region"
   role_arn = "arn:aws:iam::xxxx:role/DeployerRole"
   platform_domain_name = "your.domain"
   ```

⚠️ Ensure you have carefully reviewed all variables and replaced mock values with yours.

3. Initialize the backend and apply the changes:

```bash
  terraform init --var-file <fileName>.tfvars
  terraform plan --var-file <fileName>.tfvars
  terraform apply --var-file <fileName>.tfvars
```
### 4.6.3. Terraform backend resources deployment

This step covers the creation of:
* S3 bucket with policy to store terraform states
* DynamoDB to support state locking and consistency checking

To create an S3 bucket for storing Terraform state files, follow the steps below:

1. Navigate to codemie-aws-remote-backend folder:
   ```bash
   cd ../codemie-aws-remote-backend
   ```
2. Review the input variables for Terraform in the `deployment/terraform-scripts/columbia-sre-remote-backend/variables.tf` file and create a `<filename>.tfvars` in the repo to change default variables values there in a format of key-value. For example:
 ```
   region = "your-region"
   role_arn = "arn:aws:iam::xxxxxxxx:role/AIRunDeployerRole" # The ARN of the IAM role that will be used for deployment. Note: This value becomes available after running the terraform apply command in Step 4.6.2.
   s3_states_bucket_name = "" # Example: ai-run-terraform-states. Ensure this is a new and unique name following S3 naming rules.
   table_name = "" # Example: ai-run_terraform_locks. Ensure this is a new and unique name
```
ℹ️ Ensure you have carefully reviewed all variables and replaced mock values with yours.

3.Initialize the backend and apply the changes:
```bash
  terraform init --var-file <fileName>.tfvars
  terraform plan --var-file <fileName>.tfvars
  terraform apply --var-file <fileName>.tfvars
```
The created S3 bucket will be used for all subsequent infrastructure deployments.

### 4.6.4. Terraform Platform

This step will cover the following topics:
* Create the EKS Cluster
* Create the AWS ASGs for the EKS Cluster
* Create the AWS ALB
* Create the AWS NLB
* Create the AWS KMS key to encrypt and decrypt sensitive data in the AI/Run CodeMie application.
* Create the AWS IAM Role to access the AWS KMS and Bedrock services
* Create the AWS IAM role ExternalSecretOperator to use AWS Systems Manager

To accomplish the tasks outlined above, follow these steps:

1. Navigate to codemie-aws-platform folder:
   ```bash
   cd ../codemie-aws-platform
   ```
2. Review the input variables for Terraform in the `deployment/terraform-scripts/codemie-aws-platform/variables.tf` file and create a `<filename>.tfvars` in the repo to manage custom variables there in a format of key-value. For example:
```
region                        = "<REGION>" # Example: us-east-1
role_arn                      = "arn:aws:iam::xxxxxxxx:role/AIRunDeployerRole" # The ARN of the IAM role that will be used for deployment. Note: This value becomes available after running the terraform apply command in Step 4.6.2.
platform_domain_name          = "<DOMAIN NAME>" # Example: example.com.  The value should be taken from the Route 53 hosted zone created in the previous
platform_name                 = "<Any Value>"
platform_cidr                 = "10.0.0.0/16"
subnet_azs = [<SUBNET AZS>] # Example: '["us-east-1a", "us-east-1b", "us-east-1c"]'
private_cidrs = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
public_cidrs = ["10.0.12.0/24", "10.0.13.0/24", "10.0.14.0/24"]
ssl_policy                    = "ELBSecurityPolicy-TLS-1-2-2017-01"
eks_admin_role_arn            =  "<eks_admin_role_arn>" # Specify the ARN of the IAM role with permissions to manage the EKS cluster.
add_userdata                  = ""
spot_instance_types = [{ instance_type = "m6a.2xlarge" }]
spot_max_nodes_count          = 0
spot_desired_nodes_count      = 0
spot_min_nodes_count          = 0
demand_instance_types = [{ instance_type = "m6a.2xlarge" }]
demand_max_nodes_count        = 2
demand_desired_nodes_count    = 2
demand_min_nodes_count        = 1
```
ℹ️ Ensure you have carefully reviewed all variables and replaced mock values with yours

3. Initialize the platform and apply the changes:
   The bucket_name and dynamodb_table_name values becomes available after running the terraform apply command in Step 4.6.2
```bash
  terraform init \
        -backend-config="bucket=<bucket_name>" \
        -backend-config="key=<aws_region>/codemie/platform_terraform.tfstate" \
        -backend-config="region=<aws_region>" \
        -backend-config="acl=bucket-owner-full-control" \
        -backend-config="dynamodb_table=<dynamodb_table_name>" \
        -backend-config="encrypt=true" \
	--var-file <fileName>.tfvars
  terraform plan --var-file <fileName>.tfvars
  terraform apply --var-file <fileName>.tfvars
```
### 4.6.5. Terraform RDS (Deploying a database independently, instead of running it in a container, can be accomplished by following the instructions.)

1. Navigate to codemie-aws-platform folder:
   ```bash
   cd ../codemie-aws-rds

2. Review the input variables for Terraform in the deployment/terraform-scripts/codemie-aws-rds/variables.tf file and create a <filename>.tfvars in the repo to change default variables values there in a format of key-value. For example:
```
region                      = "<aws_region>"
role_arn                    = "arn:aws:iam::xxxxxxxx:role/AIRunDeployerRole" # The ARN of the IAM role that will be used for deployment. Note: This value becomes available after running the terraform apply command in Step 4.6.2.
platform_name               = "<platform_name>" # Use the value from step 4.6.4. .tfvars file
vpc_state_bucket            = "<bucket_name>" # The value becomes available after running the terraform apply command in Step 4.6.2
vpc_state_key               = "<aws_region>/codemie/platform_terraform.tfstate" # Replace <aws_region> before run command
backend_lock_dynamodb_table = "<dynamodb_table_name>"  # The value becomes available after running the terraform apply command in Step 4.6.2
...
```
3. Initialize the RDS and apply the changes:
```bash
  terraform init --var-file <filename>.tfvars
  terraform plan --var-file <filename>.tfvars
  terraform apply --var-file <filename>.tfvars
```
</details>

# 5. AI Models Integration and Configuration

> 📋 **Model Information**:
> 1. [Find the supported model IDs (deployment_name) in the AWS Bedrock documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/models-supported.html)
> 2. [Find cost information for AWS Bedrock models](https://aws.amazon.com/bedrock/pricing/)

Example of providing LLM and embedding models for the custom environment:

1. Go to the `deployment/helm-scripts/codemie-api/values-aws.yaml` file
2. Fill the following values to create and mount custom configmap to AI/Run pod:

<details>
<summary>Expand this section for configuration details:</summary>

```yaml
  extraObjects:
     - apiVersion: v1
       kind: ConfigMap
       metadata:
          name: codemie-llm-customer-config
       data:
          llm-amnaairn-config.yaml: |
             llm_models:
               - base_name: "amazon-nova-pro"
                 deployment_name: "eu.amazon.nova-pro-v1:0"
                 label: "Bedrock Nova Pro"
                 multimodal: true
                 enabled: true
                 default: true
                 provider: "aws_bedrock"
                 max_output_tokens: 10000
                 cost:
                   input: 0.00000105
                   output: 0.0000002625

             #  - base_name: "amazon-nova-lite"
             #    deployment_name: "eu.amazon.nova-lite-v1:0"
             #    label: "Bedrock Nova Lite"
             #    multimodal: true
             #    enabled: true
             #    provider: "aws_bedrock"
             #    max_output_tokens: 10000
             #    cost:
             #      input: 0.000000078
             #      output: 0.0000000195

             #  - base_name: "amazon-nova-micro"
             #    deployment_name: "eu.amazon.nova-micro-v1:0"
             #    label: "Bedrock Nova Micro"
             #    multimodal: false
             #    enabled: true
             #    provider: "aws_bedrock"
             #    max_output_tokens: 10000
             #    cost:
             #      input: 0.000000046
             #      output: 0.0000000115

             embeddings_models:
               - base_name: "titan"
                 deployment_name: "amazon.titan-embed-text-v1"
                 label: "Titan Embeddings G1 - Text"
                 enabled: true
                 default: true
                 provider: "aws_bedrock"
                 cost:
                   input: 0.0000001
                   output: 0
```
</details>

# 6. EPAM AI/Run™ for AWS Migration and Modernization Components Deployment

## 6.1. Overview

This section describes the process of the main EPAM AI/Run™ for AWS Migration and Modernization components deployment to the AWS EKS cluster.

### 6.1.1. Core AI/Run CodeMie Components:

ℹ️ EPAM AI/Run™ for AWS Migration and Modernization current versions of artifacts: **2.2.1-aws**

<details>
<summary> Expand the section to review all required AI/Run components:</summary>

| Component name | Images | Description |
|---------------|--------|-------------|
| AI/Run CodeMie API | valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems/codemie | The backend service of the EPAM AI/Run™ for AWS Migration and Modernization application responsible for business logic, data processing, and API operations |
| AI/Run CodeMie UI | valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems/codemie-ui | The frontend service of the EPAM AI/Run™ for AWS Migration and Modernization application that provides the user interface for interacting with the system |
| AI/Run CodeMie Nats Auth Callout | valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems/codemie-nats-auth-callout | Authorization component of EPAM AI/Run™ for AWS Migration and Modernization Plugin Engine that handles authentication and authorization for the NATS messaging system |
| AI/Run CodeMie MCP Connect | valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems/codemie-mcp-connect-service | A lightweight bridge tool that enables cloud-based AI services to communicate with local Model Content Protocol (MCP) servers via protocol translation while maintaining security and flexibility |
| AI/Run Mermaid Server | valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems/mermaid-server | Implementation of open-source service that generates image URLs for diagrams based on the provided Mermaid code for workflow visualization |

</details>

### 6.1.2. Required Third-Party Components:

<details>
<summary> Expand the section to review all required 3d party components:</summary>

| Component name | Images | Description |
|---------------|--------|-------------|
| Ingress Nginx Controller | registry.k8s.io/ingress-nginx/controller:x.y.z | Handles external traffic routing to services within the Kubernetes cluster. The EPAM AI/Run™ for AWS Migration and Modernization application uses oauth2-proxy, which relies on the Ingress Nginx Controller for proper routing and access control |
| Storage Class | - | Provides persistent storage capabilities |
| Elasticsearch |   docker.elastic.co/elasticsearch/elasticsearch:x.y.z | Database component that stores all EPAM AI/Run™ for AWS Migration and Modernization data, including datasources, projects, and other application information |
| Kibana | docker.elastic.co/kibana/kibana:x.y.z | Web-based analytics and visualization platform that provides visualization of the data stored in Elasticsearch. Allows monitoring and analyzing EPAM AI/Run™ for AWS Migration and Modernization data |
| Postgres-operator | registry.developers.crunchydata.com/crunchydata/postgres-operator:x.y.z | Manages PostgreSQL database instances required by other components in the stack. Handles database lifecycle operations |
| Keycloak-operator | epamedp/keycloak-operator:x.y.z | Manages Keycloak identity and access management instance and its configuration |
| Keycloak | docker.io/busybox:x.y.z, quay.io/keycloak/keycloak:x.y.z, registry.developers.crunchydata.com/crunchydata/crunchy-postgres:x.y.z | Identity and access management solution that provides authentication and authorization capabilities for integration with oauth2-proxy component |
| OAuth2-Proxy | quay.io/oauth2-proxy/oauth2-proxy:x.y.z | Authentication middleware that provides secure authentication for the EPAM AI/Run™ for AWS Migration and Modernization application by integrating with Keycloak or any other IdP |
| NATS | nnats:x.y.z, natsio/nats-server-config-reloader:x.y.z | Message broker that serves as a crucial component of the EPAM AI/Run™ for AWS Migration and Modernization Plugin Engine, facilitating communication between services |
| FluentBit | cr.fluentbit.io/fluent/fluent-bit:x.y.z | FluentBit enables logs and metrics collection from EPAM AI/Run™ for AWS Migration and Modernization enabling the agents observability |
| PostgreSQL | docker.io/bitnami/postgresql | Database component that stores all EPAM AI/Run™ for AWS Migration and Modernization data, including datasources, projects, and other application information |

</details>

## 6.2. Scripted Components Installation

1. Navigate helm-scripts folder:
   ```bash
   cd ../helm-scripts

2. Run the following command if using a Unix-like operating system:
   ```bash
   chmod +x helm-charts.sh

3. Add the Bitnami Helm repository by running the following command:

   ```bash
   helm repo add bitnami https://charts.bitnami.com/bitnami
   helm repo update
   ```
4. Run deployment script, possible flags:

   `--image-repository valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems`    #required flag

   `--version=2.2.1-aws;`                                              #required flag

   `--rds-disable`                                                     # If the flag was used previously, ensure it is utilized here as well.

```bash
  bash ./helm-charts.sh --version=2.2.1-aws --image-repository valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems
```
```bash
  ./helm-charts.sh --version=2.2.1-aws --image-repository valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems
```

> ⚠️ **Important**: If you are going to deploy AI TestMate also, please add the following values to the deployment/helm-scripts/codemie-api/values-aws.yaml file.
> <details>
> <summary>Required Properties for TestMate Integration </summary>
>
>```yaml
> extraVolumes: |
>  - name: codemie-authorized-applications
>    configMap:
>      name: codemie-authorized-applications
> extraVolumeMounts: |
>  - name: codemie-authorized-applications
>    mountPath: /app/config/authorized_applications/authorized-applications-config.yaml
>    subPath: authorized-applications-config.yaml
>
> extraObjects:
> - apiVersion: v1
>   kind: ConfigMap
>   metadata:
>     name: codemie-authorized-applications
>   data:
>     authorized-applications-config.yaml: |
>        authorized_applications:
>           - name: service-account-aitestmate
>             public_key_url: https://exampl.com/api/public-key
>             allowed_resources:
>               - datasource
>           - name: aitestmate
>             public_key_url: https://exampl/api/public-key
>             allowed_resources:
>              - datasource
>```
> </details>

⚠️ **Important**: If you update ConfigMaps either manually or through a Helm upgrade, you must restart the affected pods to apply the changes. Neither manual updates nor Helm upgrades automatically restart pods, so any changes to ConfigMaps will not take effect until the pods are restarted.

## 6.3. Manual Components Installation
If the previous step has already been completed, please proceed to skip this step.

<details>

<summary>If you prefer to manually deploy step by step, expand this section for more instructions:</summary>

### 6.3.1. Set up kubectl config and login in ecr
Run next command

```bash
  aws eks update-kubeconfig --region <REGION> --name <PLATFORM_NAME>
  aws ecr get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems
```

### 6.3.2. Nginx Ingress controller

Install only in case if your EKS cluster does not have Nginx Ingress Controller.

1. Create Kubernetes namespace e.g. `ingress-nginx` with the command:

```bash
   kubectl create namespace ingress-nginx
```
2. Navigate helm-scripts folder
```bash
  cd ../helm-scripts
```
3. Install ingress-nginx helm chart in created namespace:
```bash
   helm upgrade --install ingress-nginx ingress-nginx/. -n ingress-nginx --values ingress-nginx/values-aws.yaml --wait --timeout 900s --dependency-update
```
### 6.3.3. AWS gp3 storage class:

Install only in case if your EKS cluster does not have AWS gp3 storage class:

```bash
  kubectl apply -f storage-class/storageclass-aws-gp3.yaml
```
### 6.3.4. Install Elasticsearch component:

1. Create Kubernetes namespace, e.g. `elastic` with the command:

   ```bash
   kubectl create namespace elastic
   ```
2. Create Kubernetes secret:
``` bash
   kubectl -n elastic create secret generic elasticsearch-master-credentials \
   --from-literal=username=elastic \
   --from-literal=password="$(openssl rand -base64 12)" \
   --type=Opaque \
   --dry-run=client -o yaml | kubectl apply -f -
```
Secret example:
```
   apiVersion: v1
   kind: Secret
   metadata:
      name: elasticsearch-master-credentials
   type: Opaque
   data:
      username: <base64-encoded-username>
      password: <base64-encoded-password>
```
3. Install elasticsearch helm chart in created namespace with the command:
``` bash
   helm upgrade --install elastic elasticsearch/. -n elastic --values elasticsearch/values-aws.yaml --wait --timeout 900s --dependency-update
```

### 6.3.5. Install Kibana component:

1. Fill in missing values in values-aws.yaml in `kibana/values-aws.yaml` file:
   a. Replace `%%DOMAIN%%` with your domain name, e.g. `example.com`. The value should be taken from the Route 53 hosted zone that was created during an earlier step of this guide.

2. Install `kibana` helm chart with the command:

   ```bash
   helm upgrade --install kibana kibana/. -n elastic --values kibana/values-aws.yaml --wait --timeout 600s --dependency-update
   ```
3. Kibana can be accessed by the following URL: https://kibana.%%DOMAIN%%, e.g https://kibana.example.com
### 6.3.6. Install Postgres-operator component:
Apply postgres-operator chart:
   ```bash
   helm upgrade --install postgres-operator postgres-operator-helm/. -n postgres-operator --create-namespace --wait --timeout 900s --dependency-update
   ```
### 6.3.7. Install Keycloak-operator component:

1. Create `security` namespace and `keycloak-admin` secret:
   ```bash
   kubectl create namespace security

   kubectl -n security create secret generic keycloak-admin \
     --from-literal=username=admin \
     --from-literal=password="$(openssl rand -base64 12)" \
     --type=Opaque \
     --dry-run=client -o yaml | kubectl apply -f -
   ```
2. Apply keycloak-operator helm chart with the command:
   ```bash
   helm upgrade --install keycloak-operator-helm keycloak-operator-helm/. -n security --create-namespace --values keycloak-operator-helm/values.yaml --wait --timeout 900s --dependency-update
    ```
### 6.3.8. Install Keycloak component:
1. Fill in missing values in values-aws.yaml file in `keycloak-helm/values-aws.yaml` file:
   a. Replace `%%DOMAIN%%` with your domain name, e.g. `example.com`. The value should be taken from the Route 53 hosted zone that was created during an earlier step of this guide.

2. Apply `keycloak` helm chart with the command:

   ```bash
   helm upgrade --install keycloak keycloak-helm/. -n security --values keycloak-helm/values-aws.yaml --wait --timeout 900s --dependency-update
   ```
Keycloak Admin UI can be accessed by the following URL: https://keycloak.%%DOMAIN%%/auth/admin , e.g. https://keycloak.example.com/auth/admin

### 6.3.9. Install AI/Run CodeMie NATS component:

To deploy a NATS, follow the steps below:

1. Create `codemie` namespace with the command:

  ```bash
   kubectl create namespace codemie
   ```

2. Create `codemie-nats-secrets` Kubernetes secret. To set up it, follow these steps to generate and encode the necessary values:
   a. NATS_URL
    * Once the NATS is deployed in the same namespace as the AI/Run CodeMie and NATS Callout services, use the internal URL `https://codemie-nats:4222`
    * Base64 encode this URL before using it in the secret.
   b. CALLOUT_USERNAME
    * Use the username `callout`.
    * Base64 encode this username before using it in the secret.
   c. CALLOUT_PASSWORD
    * Generate a secure password using the command: `pwgen -s -1 25`.
    * Base64 encode this password before using it in the secret.
   d. CALLOUT_BCRYPTED_PASSWORD
    * Use the NATS server to generate a bcrypt-hashed password based on the `CALLOUT_PASSWORD`.
    * Command: `nats server passwd -p <CALLOUT_PASSWORD>`
    * Base64 encode the bcrypt-hashed password before using it in the secret.
   e. CODEMIE_USERNAME
    * Use the username `codemie`.
    * Base64 encode this username before using it in the secret.
   f. CODEMIE_PASSWORD
    * Generate a secure password using the command: `pwgen -s -1 25`.
    * Base64 encode this password before using it in the secret.
   g. CODEMIE_BCRYPTED_PASSWORD
    * Use the NATS server to generate a bcrypt-hashed password based on the `CODEMIE_PASSWORD`.
    * Command: `nats server passwd -p <CODEMIE_PASSWORD>`
    * Base64 encode the bcrypt-hashed password before using it in the secret.
   h. ISSUER_NKEY and ISSUER_NSEED
    * Use the `nsc` tool to generate NATS account keys. For example: `https://natsbyexample.com/examples/auth/nkeys/cli`
    * Command: `nsc generate nkey account`
    * Base64 encode the NKEY and NSEED before using them in the secret.
   i. ISSUER_XKEY and ISSUER_XSEED
    * Use the `nsc` tool to generate NATS curve keys. For example: `https://natsbyexample.com/examples/auth/nkeys/cli`
    * Command: `nsc generate nkey signing`
    * Base64 encode the XKEY and XSEED before using them in the secret.

Secret example:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: codemie-nats-secrets
type: Opaque
data:
  NATS_URL: <base64-encoded-nats-url>
  CALLOUT_USERNAME: <base64-encoded-callout-username>
  CALLOUT_PASSWORD: <base64-encoded-callout-password>
  CALLOUT_BCRYPTED_PASSWORD: <base64-encoded-callout-bcrypted-password>
  CODEMIE_USERNAME: <base64-encoded-codemie-username>
  CODEMIE_PASSWORD: <base64-encoded-codemie-password>
  CODEMIE_BCRYPTED_PASSWORD: <base64-encoded-codemie-bcrypted-password>
  ISSUER_NKEY: <base64-encoded-issuer-nkey>
  ISSUER_NSEED: <base64-encoded-issuer-nseed>
  ISSUER_XKEY: <base64-encoded-issuer-xkey>
  ISSUER_XSEED: <base64-encoded-issuer-xseed>
```
Use the following command echo -n 'your-value-here' | base64 to encode secret or use kubectl to create secret from (i.e. kubectl -n codemie create secret generic --from-literal NATS_URL=https://codemie-nats:4222 --from-literal CALLOUT_USERNAME=callout ...)
Alternatively, a Bash script can be used
```bash

#!/bin/bash

set -euo pipefail

namespace="codemie"
secret_name="codemie-nats-secrets"


log_message() {
local status="$1"
local message="$2"
local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    case "$status" in
        "success")
            echo -e "[$timestamp] [OK] $message" ;;
        "fail")
            echo -e "[$timestamp] [ERROR] $message" ;;
        "info")
            echo -e "[$timestamp] $message" ;;
        "warn")
            echo -e "[$timestamp] [WARN] $message" ;;
        *)
            echo -e "[$timestamp] $message" ;;
    esac
}

log_message "info" "Creating secret '$secret_name' in namespace '$namespace'..."
callout_password=$(openssl rand -hex 16)
codemie_password=$(openssl rand -hex 16)
bcrypted_callout_password=$(htpasswd -bnBC 10 "" "${callout_password}" | tr -d ':\n' | sed 's/$2y/$2a/')
bcrypted_codemie_password=$(htpasswd -bnBC 10 "" "${codemie_password}" | tr -d ':\n' | sed 's/$2y/$2a/')

ISSUER_NKEY=""
ISSUER_NSEED=""
log_message "info" "Creating secret '$secret_name' in namespace '$namespace'..."
output_nkey_account=$(nsc generate nkey --account 2>&1)
log_message "info" "Creating secret '$secret_name' in namespace '$namespace'..."
while IFS= read -r line; do
if [[ $line == A* ]]; then
ISSUER_NKEY="$line"
log_message "info" "ISSUER_NKEY: 123456789"
elif [[ $line == S* ]]; then
ISSUER_NSEED="$line"
log_message "info" "ISSUER_NKEY: asdfghjk"
fi
done <<< "$output_nkey_account"
if [[ -n $ISSUER_NKEY && -n $ISSUER_NSEED ]]; then
log_message "info" "ISSUER_NKEY: ${ISSUER_NKEY:0:8}...${ISSUER_NKEY: -8}"
log_message "info" "ISSUER_NSEED: ${ISSUER_NSEED:0:8}...${ISSUER_NSEED: -8}"
else
log_message "fail" "Either ISSUER_NKEY or ISSUER_NSEED is empty."
exit 1
fi

ISSUER_XKEY=""
ISSUER_XSEED=""
output_nkey_curve=$(nsc generate nkey --curve 2>&1)
while IFS= read -r line; do
if [[ $line == X* ]]; then
ISSUER_XKEY="$line"
elif [[ $line == S* ]]; then
ISSUER_XSEED="$line"
fi
done <<< "$output_nkey_curve"
if [[ -n $ISSUER_XKEY && -n $ISSUER_XSEED ]]; then
log_message "info" "ISSUER_XKEY: ${ISSUER_XKEY:0:8}...${ISSUER_XKEY: -8}"
log_message "info" "ISSUER_XSEED: ${ISSUER_XSEED:0:8}...${ISSUER_XSEED: -8}"
else
log_message "fail" "Either ISSUER_XKEY or ISSUER_XSEED is empty."
exit 1
fi

kubectl -n "$namespace" create secret generic "$secret_name" \
--from-literal=NATS_URL="nats://codemie-nats:4222" \
--from-literal=CALLOUT_USERNAME="callout" \
--from-literal=CALLOUT_PASSWORD="${callout_password}" \
--from-literal=CALLOUT_BCRYPTED_PASSWORD="${bcrypted_callout_password}" \
--from-literal=CODEMIE_USERNAME="codemie" \
--from-literal=CODEMIE_PASSWORD="${codemie_password}" \
--from-literal=CODEMIE_BCRYPTED_PASSWORD="${bcrypted_codemie_password}" \
--from-literal=ISSUER_NKEY="${ISSUER_NKEY}" \
--from-literal=ISSUER_NSEED="${ISSUER_NSEED}" \
--from-literal=ISSUER_XKEY="${ISSUER_XKEY}" \
--from-literal=ISSUER_XSEED="${ISSUER_XSEED}" \
--type=Opaque -o yaml
```

3. Install codemie-nats helm chart in created namespace, applying custom values file with the command:
```bash
  helm repo add nats https://nats-io.github.io/k8s/helm/charts/
  helm repo update nats
  helm upgrade --install codemie-nats nats/nats --version 1.2.6 \
  --namespace codemie --values ./codemie-nats/values-aws.yaml \
  --wait --timeout 900s
```


ℹ️ In AWS, if TLS termination for Plugin Engine load balancer is handled by NLB (TLS certificate is on LB itself) then Plugin Engine NATS URL should start with tls protocol, for example: tls://codemie-nats.example.com:30422 , otherwise use nats://codemie-nats.example.com:30422

### 6.3.10. Install AI/Run CodeMie NATS Auth Callout component:

To deploy a NATS Auth Callout service, follow the steps below:

1. Fill in missing values in values.yaml and Chart.yaml files in `codemie-nats-auth-callout` folder:
   a. Replace `%%IMAGE_VERSION%%` with next value `2.2.1-aws`
   b. Replace `%%IMAGE_REPOSITORY%%` with next value `valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems`

2. Install `codemie-nats-auth-callout` helm chart, applying custom values file with the command:

```bash
  helm upgrade --install codemie-nats-auth-callout codemie-nats-auth-callout/. \
  --version "2.2.1-aws" \
  --namespace "codemie" \
  -f "codemie-nats-auth-callout/values-aws.yaml" \
  --wait \
  --timeout 600s \
  --dependency-update
```

### 6.3.11. Install AI/Run CodeMie MCP Connect component:

1. Fill in missing values in values.yaml and Chart.yaml files in `codemie-mcp-connect-service` folder:
   a. Replace `%%IMAGE_VERSION%%` with next value `2.2.1-aws`
   b. Replace `%%IMAGE_REPOSITORY%%` with next value `valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems`

2. Install `mcp-connect` helm chart with the command:

```bash
  helm upgrade --install codemie-mcp-connect-service codemie-mcp-connect-service/. \
    --version 2.2.1-aws \
    --namespace "codemie" \
    -f "./codemie-mcp-connect-service/values.yaml" \
    --wait \
    --timeout 600s \
    --dependency-update
```

### 6.3.12. Install PostgreSQL component:

#### 6.3.12.1. By default, AWS RDS Database was set up previously during instruction, Use next step

1. Navigate to `deployment/terraform-scripts/codemie-aws-rds` and run next command for get credentials ro RDS
```bash
   terraform output -raw address
   terraform output -raw database_name
   terraform output -raw database_user
   terraform output -raw database_password
```

2. Create `codemie-postgresql` secret with postgresql passwords replace AWS_RDS values placeholders from 4.6.5 step

```bash
  kubectl -n "codemie" create secret generic "codemie-postgresql" \
         --from-literal=password="${AWS_RDS_DATABASE_PASSWORD}" \
         --from-literal=user="${AWS_RDS_DATABASE_USER}" \
         --from-literal=db-url="${AWS_RDS_ADDRESS}" \
         --from-literal=db-name="${AWS_RDS_DATABASE_NAME}"
```

#### 6.3.12.2. If flag --rds-disable was used, means RDS wasn't set up previously during instruction, Use next step

1. Create `codemie-postgresql` secret with postgresql passwords:

```bash
  kubectl create secret generic codemie-postgresql \
  --from-literal=password=$(openssl rand -base64 12) \
  --from-literal=postgres-password=$(openssl rand -base64 12) \
  --namespace codemie
```
```
apiVersion: v1
kind: Secret
metadata:
name: codemie-postgresql
namespace: codemie
data:
password: <base64-encoded-password>
postgres-password: <base64-encoded-postgres-password>
type: Opaque
```
2. Install PostgreSQL helm chart with the command:
```bash
  helm repo add bitnami https://charts.bitnami.com/bitnami

  helm repo update

  helm upgrade --install codemie-postgresql bitnami/postgresql \
  --version 16.7.4 \
  --values ./codemie-postgresql/values-aws.yaml \
  --namespace codemie \
  --wait --timeout 600s \
  --dependency-update
```

### 6.3.13. Install OAuth2 Proxy component:

Authentication middleware that provides secure authentication for the EPAM AI/Run™ for AWS Migration and Modernization application by integrating with Keycloak

1. Create Kubernetes namespace, e.g. `oauth2-proxy` with the command:

```bash
   kubectl create namespace oauth2-proxy
```

2. Create `oauth2-secret` with keycloak client data:

```bash
  kubectl create secret generic oauth2-proxy \
  --namespace=oauth2-proxy \
  --from-literal=client-id='codemie' \
  --from-literal=client-secret="$(openssl rand -base64 12)" \
  --from-literal=cookie-secret=$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_' ; echo) \
  --type=Opaque
```

```
apiVersion: v1
kind: Secret
metadata:
  name: oauth2-proxy
  namespace: oauth2-proxy
data:
  client-id: <base64-encoded-client-id>
  client-secret: <base64-encoded-client-secret>
  cookie-secret: <base64-encoded-cookie-secret>
type: Opaque
```
3. Copy keycloak  secret to oauth2-proxy  namespace:
```bash
  kubectl get secret keycloak-admin -n security -o yaml | sed '/namespace:/d' | kubectl apply -n oauth2-proxy -f -
```

4. Fill in missing values in values-aws.yaml in `kibana/values-aws.yaml` file:
   a. Replace `%%DOMAIN%%` with your domain name, e.g. `example.com`. The value should be taken from the Route 53 hosted zone that was created during an earlier step of this guide.

5. Install oauth2-proxy helm chart in created namespace with the command:
```bash
  helm upgrade --install oauth2-proxy oauth2-proxy/. -n oauth2-proxy --values oauth2-proxy/values-aws.yaml --wait --timeout 900s --dependency-update
```
### 6.3.14. Install AI/Run CodeMie UI component:

1. Fill in missing values in values-aws.yaml and Chart.yaml files in `codemie-ui` folder:
   a. Replace `%%IMAGE_VERSION%%` with next value `2.2.1-aws`
   b. Replace `%%IMAGE_REPOSITORY%%` with next value `valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems`
   c. Replace `%%DOMAIN%%` with your domain name, e.g. `example.com`. The value should be taken from the Route 53 hosted zone that was created during an earlier step of this guide.

2. Install `codemie-ui` helm chart in created namespace, applying custom values file with the command:

```bash
  helm upgrade --install codemie-ui codemie-ui/. \
  --version 2.2.1-aws \
  --namespace "codemie" \
  -f "./codemie-ui/values-aws.yaml" \
  --wait \
  --timeout 180s \
  --dependency-update
```
### 6.3.15. Install AI/Run Mermaid Server component:
1. Fill in missing values in values.yaml and Chart.yaml files in `mermaid-server` folder:
   a. Replace `%%IMAGE_VERSION%%` with next value `2.2.1-aws`
   b. Replace `%%IMAGE_REPOSITORY%%` with next value`valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems`

2. Install mermaid-server helm chart with the command:

```bash
  helm upgrade --install mermaid-server mermaid-server/. \
  --version 2.2.1-aws \
  --namespace "codemie" \
  -f "./mermaid-server/values.yaml" \
  --wait --timeout 600s \
  --dependency-update
```
### 6.3.16. Install AI/Run CodeMie API component:

1. Fill in missing values in values.yaml and Cart.yaml files in `codemie-api` folder:
   a. Replace `%%DOMAIN%%` with your domain name, e.g. `example.com`. The value should be taken from the Route 53 hosted zone that was created during an earlier step of this guide.
   b. Replace `%%AWS_DEFAULT_REGION%%` with your AWS region, the value becomes available after running the terraform apply command in Step 4.6.5, e.g. `us-west-2`
   c. Replace `%%EKS_AWS_ROLE_ARN%%` with your AWS IAM Role arn, the value becomes available after running the terraform apply command in Step 4.6.5, e.g. `arn:aws:iam::0123456789012:role/AWSIRSA_AI_RUN`
   d. Replace `%%AWS_KMS_KEY_ID%%` with your KMS Key ID, the value becomes available after running the terraform apply command in Step 4.6.5, e.g. `50f3f093-dc86-48de-8f2d-7a76e480348e`
   e. Replace `%%AWS_S3_BUCKET_NAME%%`  The value becomes available after running the terraform apply command in Step 4.6.5
   f. Replace `%%IMAGE_REPOSITORY%%` with next value`valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems`
   g. Replace `%%IMAGE_VERSION%%` with next value `2.2.1-aws`

2. Copy Elasticsearch credentials to the application namespace with the command:

```bash

kubectl get secret elasticsearch-master-credentials -n elastic -o yaml | sed '/namespace:d/' | kubectl apply -n codemie -f -
```
3. Install codemie-api helm chart, applying custom values file with the command:
```bash
  helm upgrade --install codemie-api codemie-api/. \
  --version 2.2.1-aws \
  --namespace "codemie" \
  -f "./codemie-api/values-aws.yaml"  \
  --wait --timeout 600s \
  --dependency-update
```
4. AI/Run CodeMie UI can be accessed by the following URL: https://codemie.%%DOMAIN%% , e.g. https://codemie.example.com

### 6.3.17. Install Fluentbit component

If you do not have your own logging system then consider installing Fluentbit component to store historical log data.

1. Create `fluentbit` namespace:

```bash
  kubectl create ns fluentbit
```

2. Copy Elasticsearch credentials to the fluentbit namespace with the command:
```bash
  kubectl get secret elasticsearch-master-credentials -n elastic -o yaml | sed '/namespace:/d' | kubectl apply -n fluentbit -f -
```
3. Fill in missing values in values.yaml file in `fluent-bit/values-aws.yaml` file:
   a. Replace `%%AWS_REGION%%` with your AWS region, the value becomes available after running the terraform apply command in Step 4.6.5, e.g. `us-west-2`

4. Install fluentbit with the command:
```bash
  helm upgrade --install fluent-bit fluent-bit/. -n fluentbit --values fluent-bit/values.yaml --wait --timeout 900s --dependency-update
```

</details>

# 7. Provide access to the application

## 7.1. Create new security group
### 7.1.1. Open EC2 service group

<img src="assets/deployment-guide/security_group_7_1_1.png">

### 7.1.2. Open "Security Groups"

<img src="assets/deployment-guide/security_group_7_1_2.png">

### 7.1.3. Create new "Security Groups""

<img src="assets/deployment-guide/security_group_7_1_3.png">

<img src="assets/deployment-guide/security_group_7_1_3_2.png">

## 7.2. Add security group to Load Balancers
### 7.2.1. Open  Load Balancers

<img src="assets/deployment-guide/load_balancer_7_2_1.png">

### 7.2.2. Find and open  <some name>-ingress-alb balancer to cluster which was created


<img src="assets/deployment-guide/load_balancer_7_2_2.png">

### 7.2.3. Navigate to security tab and click "edit" button

<img src="assets/deployment-guide/load_balancer_7_2_3.png">

### 7.2.4. Add new security group and save changes

<img src="assets/deployment-guide/load_balancer_7_2_4.png">

# 8. Post-installation configuration

Before onboarding users few additional configuration steps are required:

## 8.1. Keycloak Realm configuration

### 8.1.1.Login into Keycloak console

Link to keycloak
URL = https://keycloak.<TF_VAR_platform_domain_name>/auth/admin.
Where TF_VAR_platform_domain_name the value is define in `deployment/terraform-scripts/deployment.conf` file.
Sample: `https://keycloak.example.com/auth/admin`

You can find creds in AWS Console or in the output of previously run script.

>**Option 1:**
>After running `helm-charts.sh`, Keycloak credentials are printed in terminal output.
>
><img src="assets/deployment-guide/helm_script_output.png">

> **Option 2:**
>1. Login into AWS console
>2. Open Elastic Kubernetes Service
>3. Navigate to the cluster that was set up while following the instructions
>4. Go to Resource tab
>5. Open Secrets page (Config and secrets menu item)
>6. Find "keycloak-admin" secret
>7. Click on decode buttons
>
><img src="assets/deployment-guide/keycloak_credential.png">
>
><img src="assets/deployment-guide/keycloak_credential_2.png">

### 8.1.2. Enable realm unmanaged attributes:
1. Open a left sidebar (Menu) on site
2. Choose `codemie-prod` realm
3. Click on Realm Settings
4. Select `Enabled` for "Unmanaged Attributes" parameter.

> ℹ️ When you assign a user access to a project that matches their Keycloak username (from the username claim), the system will automatically create this personal project in AI/Run CodeMie. Other projects must be created by AI/Run CodeMie admin.

### 8.1.3. Configure Client Scopes

To include the added `applications` unmanaged attribute as an additional claim to the token it's necessary to configure protocol mappers. Follow the step:
1. Navigate to "Client Scopes" and update the client scope "profile" to include the newly added attribute.

   <img src="assets/deployment-guide/create_user_keycloak_1.png">

2. Configure a mapper, selecting the mapping type as "User Attribute", then set applications as the field name, user attribute, and token claim name. Finally, save the changes.

   <img src="assets/deployment-guide/create_user_keycloak_2.png">
   <img src="assets/deployment-guide/create_user_keycloak_2_2.png">
   <img src="assets/deployment-guide/create_user_keycloak_2_3.png">

### 8.1.4. Create first user

1.Open Users list page

   <img src="assets/deployment-guide/create_user_keycloak_3.png">

2. Click on "Add user" button

   <img src="assets/deployment-guide/create_user_keycloak_4.png">

3. Fill all necessary fields and click on "Email Verified " and "Create" buttons

   <img src="assets/deployment-guide/create_user_keycloak_5.png">

4. Assign admin role and unassign default role

   <img src="assets/deployment-guide/create_user_keycloak_6_1.png">
   <img src="assets/deployment-guide/create_user_keycloak_6_2.png">
   <img src="assets/deployment-guide/create_user_keycloak_6_3.png">
   <img src="assets/deployment-guide/create_user_keycloak_6_4.png">
5. Set up credential

   <img src="assets/deployment-guide/create_user_keycloak_7_1.png">
   <img src="assets/deployment-guide/create_user_keycloak_7_2.png">

6. Set up attributes

   <img src="assets/deployment-guide/create_user_keycloak_8.png">

7. Verify login and access to EPAM AI/Run™ for AWS Migration and Modernization application.
   Link to fronted
   URL = https://codemie.<TF_VAR_platform_domain_name>

## 8.2. Create client and client secret for AI TestMate

The steps in this section apply only to the AI Testmate add-on and can be performed at any time in the future.
These steps do not affect the AI/Run™ for AWS application.

1. Log into the Keycloak admin console with your administrator credentials
2. Select the codemie-prod realm from the dropdown in the top-left corner
3. In the left sidebar menu under "Manage", click on Clients.
4. Click the Create client button to start the client creation process.
5. Type in Client ID and Name fields with value "aitestmate". Client Type should be "OpenID Connect", Switcher "Always Display in UI" should be Off
6. Configure Capability config:
   - Client Authentication - ON
   -  Authorization - OFF
   -  Standard flow - ON
   -  Direct access grants - ON
   -  Service accounts roles - ON
   -  Implicit flow - OFF
   -  OAuth 2.0 Device Authorization Grant - OFF
   -  OIDC CIBA Grant - OFF
7. Configure Login Settings:
   -  Root URL - https://codemie.example.com
   -  Home URL -
   -  Valid Redirect URIs - https://codemie.example.com/*
   -  Web Origins - https://codemie.example.com
8. Configure Service accounts roles:
   - Navigate to the Service accounts roles tab in the client settings.
   - Click on Assign role button
   - chose: Developer(see only associated projects) or Admin(see all projects) role
9. Configure Client scopes accounts roles:
   - Navigate to the Client Scopes tab in the client settings
   - Click on Add client scopes
   - Select the codemie scope from the dropdown and set the assignment type to Default.
10. Configure Service account user:
  - Navigate to the Service accounts roles tab in the client settings
  - Click on service-account-aitestmate link
  - Input Email : aitestmate@domain.com
  - Input First name: aitestmate
  - Input Last name: project
  - Click on the Attributes tab
  - Type Key: applications and Values name of your project aitestmate
  - Click Save button
11. Go to credentials. On the page you can find "Client Secret"


# 9. Cost Management

Please carefully review all billable services (depicted on deployment diagram) and their pricing [here](https://aws.amazon.com/pricing/).
The product listed on AWS Marketplace is free, but usage incurs costs associated with the AWS services it utilizes. It is recommended to review the pricing details of these services to understand potential costs.

# 10. Monitoring and Recovery

EPAM AI/Run™ for AWS Migration and Modernization application uses built-in AWS services monitoring and alerting
capabilities. Please refer to the following documentation for more details:
All logs are aggregated and published into AWS CloudWatch, categorized based on their importance:
``
   "*-important"
   "*-verbose"
``
Please consider setup alerts after the deployment.
By default, EBS snapshots are enabled for ``*-on-demand-*`` EBS volumes. You can disable this functionality after deployment.

The user data is stored in AWS RDS and AWS EBS, AWs S3 services. You can use launch templates "worker_group_on_demand-*", "worker_group_spot-*" created during deployment to restore the environment in case of failure.
More information about potential [issues](https://docs.aws.amazon.com/eks/latest/userguide/troubleshooting.html).

# 11. Maintenance
This guide relies on valid AWS credentials with sufficient permissions to create and manage resources.
Users are responsible for keeping their credentials secure and up to date. We strongly recommend enabling credential rotation
for enhanced security. Refer to the AWS documentation on credential rotation: [Rotate Your Secrets with AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/rotate-secrets_turn-on-cli.html)

The container images used in this deployment are regularly scanned for vulnerabilities. In the event of a critical vulnerability, users are responsible for updating the images in their AWS ECR repository to the latest product version and redeploying the application with the updated images. For detailed guidance, see:
[Amazon ECR Image Scanning Documentation](https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-scanning.html).

The compute infrastructure for the EKS cluster is based on self-managed node groups configured with Auto Scaling Groups using a Target Tracking Scaling Policy. Users may customize the default behavior to suit their specific scaling needs. More details are available here:
[Cluster Autoscaler for Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html).

The EC2 instances for the node groups use the AWS AMI version amazon-eks-node-al2023-x86_64-standard-1.33-v20250715. To ensure ongoing security, consider using AWS Systems Manager's Session Manager to enable automatic patching for AMIs. Learn more through the following documentation:
[AWS Systems Manager Patch Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/patch-manager.html).


# 12. Support
This is a version for educational exploration, provided free of charge, relying on community-based assistance.
For deploying enterprise-grade versions and professional help with building custom-tailored AI solutions,
contact EPAM Systems - SupportAIRunforAWS@epam.com or [EPAM Systems Contacts](https://www.epam.com/services/artificial-intelligence/epam-ai-run-tm#contact).
