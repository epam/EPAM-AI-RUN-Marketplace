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
    <td>1Gi</td>
    <td>0.2</td>
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
    <td>1Gi</td>
    <td>0.2</td>
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

For example, instance type `c5.2xlarge` has `8 vCPUs` and `16 GB RAM`. That
means you need add at least `2` to `TF_VAR_demand_max_nodes_count` and
`TF_VAR_demand_desired_nodes_count`.

**⚠️ Warning: Any manual changes made to your infrastructure after running
`terraform.sh` will be reverted**. For example, terraform will revert manual
changes made to the [security group mentioned
here](../../../README.md#71-create-new-security-group).

> You need to re-run [terraform.sh](../../terraform-scripts/terraform.sh) in
> order to apply new changes.

### Create a new OpenID Client in Keycloak

**TestMate add-on** uses AI/Run&trade; Platform API for the integration, so you
need to create a new OpenID Client in Keycloak for it.

Please, follow the [Create client and client secret for AI
TestMate](../../../README.md#82-create-client-and-client-secret-for-ai-testmate) guide.

> The detailed general guide on how to create a new OpenID Client in Keycloak can be
> found in the official [Keycloak
> documentation](https://www.keycloak.org/docs/latest/server_admin/#proc-creating-oidc-client_server_administration_guide).

Save the client secret for later use in AI TestMate configuration.

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

- `region` - AWS region where the resources will be created.
- `platform_name` - Name of the cluster where AI TestMate will be deployed.

Please see the details at [AI TestMate Terraform Deployment
Readme](https://github.com/epam/EPAM-AI-RUN-Marketplace/tree/main/deployment/add-ons/aitestmate/terraform-scripts).

## Deploy AI TestMate Helm Charts

After the infrastructure is deployed, proceed to install the AI TestMate Helm
charts.

The script which will install all necessary Helm charts for AI TestMate
deployment is provided in the `helm-charts/install.sh` file.

The script by default uses `examples/aws/values.yaml` files for each Helm
chart. Make sure to customize the `values.yaml` files for each Helm chart
according to your environment and requirements before running the installation
script.

For example, you need to set the correct auth settings, KMS settings, and other
configuration options.

You can deploy all charts using the following command from helm-charts directory:

```bash
# Usage: $0 <namespace> [container-registry] [version]

./install.sh aitestmate 000000000000.dkr.ecr.us-east-1.amazonaws.com 2.2.1-aws
```

## Using Claude Models in AWS

We are leveraging Claude models available through AWS Bedrock for our use cases. These models enable advanced generative AI capabilities powered by Anthropic.

### Recommended Models

To get started, we recommend using one of:

- `anthropic.claude-3-7-sonnet-20250219-v1:0`
- `anthropic.claude-sonnet-4-5-20250929-v1:0`

### First-Time User Requirement

As first-time users of Anthropic models, you are required to submit your use case details before gaining access. Simply select the desired model from the **Model Catalog**, open it in the playground, and follow the instructions for submitting the required details.

For further guidelines, refer to the official AWS documentation.

## Explore AI TestMate

AI TestMate user guide, as well as architecture info and administrator guide
can be found at `/docs` path of the deployed AI TestMate UI service.

