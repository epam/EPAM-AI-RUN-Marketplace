# AI/Run&trade; TestMate add-on AWS Deployment Guide

## Prerequisites

Before starting the deployment process, ensure you have the following
prerequisites in place:

- **AI/Run&trade; Platform**: Ensure that the AI/Run&trade; Platform is already
  installed and operational in your AWS environment
- **Additional Resources**: Make sure you have the necessary resources allocated
  for AI TestMate add-on, including compute, storage, and networking resources in your
  AWS environment

### Resource Requirements

Overall, AI TestMate requires an extra 8 CPU cores and 32 GB of RAM to run all
services smoothly.

However, the actual resource consumption may vary depending on your specific usage patterns and workload. For larger projects or workloads involving numerous repositories requiring test generation, you may need to assign more workers, which could require allocating additional resources.

<details>
<summary>Click to expand resource requirements table</summary>
<table>
<thead>
  <tr>
    <th>Component</th>
    <th>Replicas</th>
    <th>Memory</th>
    <th>CPU</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>UI Service</td>
    <td>1</td>
    <td>512Mi</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>API Service</td>
    <td>2</td>
    <td>2Gi</td>
    <td>0.5</td>
  </tr>
  <tr>
    <td>Database</td>
    <td>1</td>
    <td>8Gi</td>
    <td>1</td>
  </tr>
  <tr>
    <td>In-Memory Storage</td>
    <td>1</td>
    <td>1Gi</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>Message broker</td>
    <td>1</td>
    <td>1Gi</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>Worker</td>
    <td>1+</td>
    <td>10Gi</td>
    <td>2</td>
  </tr>
  <tr>
    <td>System Worker</td>
    <td>1</td>
    <td>4Gi</td>
    <td>1</td>
  </tr>
  <tr>
    <td>Celery Beat</td>
    <td>1</td>
    <td>512Mi</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>Embeddings Service</td>
    <td>1</td>
    <td>4Gi</td>
    <td>2</td>
  </tr>
  <tr>
    <td>Celery Flower</td>
    <td>1</td>
    <td>512Mi</td>
    <td>0.1</td>
  </tr>
  <tr>
    <td>Kibana</td>
    <td>1</td>
    <td>2Gi</td>
    <td>0.2</td>
  </tr>
</tbody>
</table>
</details>

## Codemie Additional Setup

In order to deploy **TestMate add-on** you need to follow additional steps after
platform is installed.

### Add additional resources

Add more nodes for your Kubernetes cluster by changing configuration
in the [deployment.conf](../../terraform-scripts/deployment.conf).

For example, instance type `m6a.2xlarge` has `8 vCPUs` and `32 GB RAM`. That
means you need add at least `1` to `TF_VAR_demand_max_nodes_count` and
`TF_VAR_demand_desired_nodes_count`. You need to re-run
[terraform.sh](../../terraform-scripts/terraform.sh) in order to apply new
changes.

**⚠️ Warning:** Resources managed by Terraform are kept in sync with its state.
**Manual edits made directly in the cloud will be undone.** For example, changes
made to the [security group](../../../README.md#71-create-new-security-group))
will be undone on the next `terraform.sh` run. Therefore, after executing the
script, it is recommended to reapply these changes to ensure the configuration
aligns with your desired state.

### Create a new OpenID Client in Keycloak

**TestMate add-on** uses AI/Run&trade; Platform API for the integration, so you
need to create a new OpenID Client in Keycloak for it.

Please, follow the [Create client and client secret for AI
TestMate](../../../README.md#82-create-client-and-client-secret-for-ai-testmate) guide.

> The detailed general guide on how to create a new OpenID Client in Keycloak can be
> found in the official [Keycloak
> documentation](https://www.keycloak.org/docs/latest/server_admin/#proc-creating-oidc-client_server_administration_guide).

Save the OpenID client's `client id` and `client secret` for later use in AI TestMate configuration.

### Create an additional setup for Codemie API deployment

**AI TestMate add-on** must be included in the list of authorized applications to
access Codemie resources.

To enable access, update the `extraObjects` section in the [Codemie API Helm
chart values](../../helm-scripts/codemie-api/values-aws.yaml) of the **Codemie
API Helm** chart.

Add the following configuration item into the `extraObjects` array, ensuring to
replace `<aitestmate-namespace>` with the correct namespace where **AI TestMate
add-on** is deployed:

```yaml
extraObjects:
  - apiVersion: v1
    kind: ConfigMap
    metadata:
      name: codemie-authorized-applications
    data:
      authorized-applications-config.yaml: |
        authorized_applications:
          - name: service-account-aitestmate
            public_key_url: http://aitestmate-nginx.<aitestmate-namespace>.svc.cluster.local/api/public-key
            allowed_resources:
              - datasource
          - name: aitestmate
            public_key_url: http://aitestmate-nginx.<aitestmate-namespace>.svc.cluster.local/api/public-key
            allowed_resources:
              - datasource
```

**AI TestMate add-on** must be enabled on UI.

To enable add-on on UI update the `codemie-customer-amna-config` config map in
the [Codemie API Helm chart
values](../../helm-scripts/codemie-api/values-aws.yaml) of the **Codemie API
Helm** chart.

The `customer-config.yaml` file follows a YAML format with a specific structure:

```yaml
components:
  - id: "componentId"
    settings:
      name: "Component Display Name"
      enabled: true|false
      url: "https://example.com/resource"
```

Add the following component definition to the `components` list in
`customer-config.yaml` key in `codemie-customer-amna-config` config map:

```yaml
- id: "applications:test-mate"
  settings:
    enabled: true
    name: "AI TestMate"
    url: "/aitestmate"
    type: "link"
    description: "Autonomous GenAI solution that automatically generates and commits unit tests, increasing coverage and reducing team effort in software development."
    created_by: "EPAM"
    icon_url: "https://static.cdn.epam.com/uploads/4e9e888a2fff48ea970beb06bbfd9c72/EPM-EAG/ai_testmate_logo_small.png"
```

Add this ConfigMap in the `extraVolumes/extraVolumeMounts` section of the [Codemie API Helm
chart values](../../helm-scripts/codemie-api/values-aws.yaml).

```yaml
extraVolumes: |
  - name: codemie-authorized-applications
    configMap:
      name: codemie-authorized-applications
extraVolumeMounts: |
  - name: codemie-authorized-applications
    mountPath: /app/config/authorized_applications/authorized-applications-config.yaml
    subPath: authorized-applications-config.yaml
```

Update the deployment with the new configuration and restart the Codemie pods to
apply the changes. You can do this by re-run:

```sh
./helm-charts.sh version=2.2.1-aws --image-repository valid-link-to-aws-ecr.dkr.ecr.us-east-1.amazonaws.com/epam-systems
```

## Deploy AI TestMate Infrastructure

Using the provided Terraform scripts, deploy the necessary infrastructure for
AI TestMate on AWS.

Use already created AWS resources to fill in the required variables in the
Terraform scripts.

- `region` - AWS region where the resources will be created. Must match AI/Run Platform region.
- `platform_name` - Name of the cluster where AI TestMate will be deployed. Must match AI/Run Platform name

Please see the details at [AI TestMate Terraform Deployment
Readme](https://github.com/epam/EPAM-AI-RUN-Marketplace/tree/main/deployment/add-ons/aitestmate/terraform-scripts).

This module has the following outputs you need in configuration steps later:

| Output                | Comment                                    |
|-----------------------|--------------------------------------------|
| worker\_role\_arn     | IAM Role for AI TestMate worker pod        |
| sysworker\_role\_arn  | IAM Role for AI TestMate system worker pod |
| api\_role\_arn        | IAM Role for AI TestMate api pod           |
| kms\_default\_key\_id | KMS default symmetric key for encryption   |
| kms\_codemie\_key\_id | KMS codemie assymetric key for integration |

## Deploy AI TestMate Helm Charts

After the infrastructure is deployed, proceed with the AI TestMate Helm charts.
Before you install helm charts you **must** configure them according to your
environment and requirements needs.

Each helm chart has default values in `values.yaml`. An example of configuration
could be found in `examples/aws/values.yaml`.

Below are the basic configuration steps required to set up and run the AI
TestMate application. Go to the [charts directory](helm-scripts/charts/) and
proceed with configuration as described below.

### Configure aitestmate-api

Update [examples/aws/values.yaml](helm-scripts/charts/aitestmate-api/examples/aws/values.yaml):

In the section `ExtraEnv` update the following values:

| Name                           | Comment                                          |
|--------------------------------|--------------------------------------------------|
| `CODEMIE_BASE_URL`             | Change domain name for codemie                   |
| `CODEMIE_GET_TOKEN_URL`        | Change domain name for keycloak                  |
| `CODEMIE_CLIENT_ID`            | OpenID client's id saved from previous steps     |
| `CODEMIE_CLIENT_SECRET`        | OpenID client's secret saved from previous steps |
| `CODEMIE_KEY_ID`               | Use `kms_codemie_key_id` from terraform output   |
| `API_AUTH_OPENID_URL_BASE`     | Change domain name for keycloak                  |
| `API_AUTH_OPENID_METADATA_URL` | Change domain name for keycloak                  |
| `API_AUTH_OPENID_CLIENT_ID`    | Use `codemie` - client for authenticating users  |
| `KMS_LOCATION_ID`              | Use same region as in terraform variables        |
| `KMS_DEFAULT_KEY_ID`           | Use `kms_default_key_id` from terraform output   |

In the section `serviceAccount.annotations` set `eks.amazonaws.com/role-arn` to
the terraform's `api_role_arn` output.

### Configure aitestmate-nginx

Update [examples/aws/values.yaml](helm-scripts/charts/aitestmate-nginx/examples/aws/values.yaml):

In the section `ingress.hosts` update the following values:

| Name                           | Comment                                          |
|--------------------------------|--------------------------------------------------|
| `host`                         | Change domain name for codemie                   |

### Configure aitestmate-sysworker

Update [examples/aws/values.yaml](helm-scripts/charts/aitestmate-sysworker/examples/aws/values.yaml):

In the section `ExtraEnv` update the following values:

| Name                    | Comment                                          |
|-------------------------|--------------------------------------------------|
| `CODEMIE_BASE_URL`      | Change domain name for codemie                   |
| `CODEMIE_GET_TOKEN_URL` | Change domain name for keycloak                  |
| `CODEMIE_CLIENT_ID`     | OpenID client's id saved from previous steps     |
| `CODEMIE_CLIENT_SECRET` | OpenID client's secret saved from previous steps |
| `CODEMIE_KEY_ID`        | Use `kms_codemie_key_id` from terraform output   |
| `KMS_LOCATION_ID`       | Use same region as in terraform variables        |
| `KMS_DEFAULT_KEY_ID`    | Use `kms_default_key_id` from terraform output   |
| `LLM_MODEL_CONFIG_NAME` | Optionally update model id to the latest version |

In the section `serviceAccount.annotations` set `eks.amazonaws.com/role-arn` to
the terraform's `sysworker_role_arn` output.

### Configure aitestmate-worker

Update [examples/aws/values.yaml](helm-scripts/charts/aitestmate-worker/examples/aws/values.yaml):

In the section `replicaCount` you may adjust number of worker to run, but keep
in mind that any value greater than 1 requires even more resources in the
cluster from the [Add additional resources](#add-additional-resources) step.

In the section `ExtraEnv` update the following values:

| Name                    | Comment                                          |
|-------------------------|--------------------------------------------------|
| `CODEMIE_BASE_URL`      | Change domain name for codemie                   |
| `CODEMIE_GET_TOKEN_URL` | Change domain name for keycloak                  |
| `CODEMIE_CLIENT_ID`     | OpenID client's id saved from previous steps     |
| `CODEMIE_CLIENT_SECRET` | OpenID client's secret saved from previous steps |
| `CODEMIE_KEY_ID`        | Use `kms_codemie_key_id` from terraform output   |
| `KMS_LOCATION_ID`       | Use same region as in terraform variables        |
| `KMS_DEFAULT_KEY_ID`    | Use `kms_default_key_id` from terraform output   |
| `LLM_MODEL_CONFIG_NAME` | Optionally update model id to the latest version |

In the section `serviceAccount.annotations` set `eks.amazonaws.com/role-arn` to
the terraform's `worker_role_arn` output.

### Deploy using install.sh

The script which will install all necessary Helm charts for AI TestMate
deployment is provided in the [helm-charts/install.sh](helm-scripts/install.sh) file.

By default it uses `examples/aws/values.yaml` files for each Helm chart.
You must specify *kubernetes namespace* where AI/Run TestMate will be deployed.
Also, you must provide *container registry* from which images will be used.

```bash
# Usage: ./install.sh <namespace> <container-registry> [version]
#   namespace: required, kubernetes namespace, e.g. aitestmate
#   container-registry: required, registry with aitestmate images, e.g. 000000000000.dkr.ecr.us-east-1.amazonaws.com
#   version: optional, override version, e.g. 2.2.1-aws

./install.sh aitestmate <valid-registry-host> 2.2.1-aws
```


## Using Claude Models in AWS

We are leveraging Claude models available through AWS Bedrock for our use cases. These models enable advanced generative AI capabilities powered by Anthropic.

### Recommended Models

To get started, we recommend using one of:

- `anthropic.claude-sonnet-4-5-20250929-v1:0`
- `anthropic.claude-3-7-sonnet-20250219-v1:0`

### First-Time User Requirement

As first-time users of Anthropic models, you are required to submit your use case details before gaining access. Simply select the desired model from the **Model Catalog**, open it in the playground, and follow the instructions for submitting the required details.

For further guidelines, refer to the official AWS documentation.

## Explore AI TestMate

AI TestMate user guide, as well as architecture info and administrator guide
can be found at `/docs` path of the deployed AI TestMate UI service.

