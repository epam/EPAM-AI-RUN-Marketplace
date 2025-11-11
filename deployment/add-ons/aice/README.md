# EPAM AI/Run&trade; AICE (AI Code Exploration) add-on AWS Deployment Guide

## Prerequisites

Before starting the deployment process, ensure you have the following
prerequisites in place:

- **AI/Run&trade; Platform**: Ensure that the AI/Run&trade; Platform is already
  installed and operational in your AWS environment
- **Additional Resources**: Make sure you have the necessary resources allocated
  for AICE (AI Code Exploration) add-on, including compute, storage, and networking resources in your
  AWS environment

## AICE Components Overview

<details>
<summary> Expand the section to review all required AI/Run AICE components:</summary>

| Component Name              | Image                                | Description                                                                                                                                                                                                                                                           |
|-----------------------------|--------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| code-exploration-ui         | aice/code-exploration-ui             | Frontend UI application for code exploration, built with React and served via Nginx. Provides the web interface for users to interact with the AICE system.                                                                                                           |
| code-analysis-datasource    | aice/code-analysis-datasource:latest | Service responsible for parsing and analyzing source code. Exposes APIs for code analysis and provides data to the main API service. Uses LSP implementations and ANTLR for code parsing and semantic analysis.                                                       |
| code-exploration-api        | aice/code-exploration-api            | Main backend API service that handles requests from the UI. Manages the code knowledge graph, interacts with Neo4j, Elasticsearch, and LLM providers to deliver code exploration capabilities. Implements hexagonal architecture for maintainability and scalability. |
| code-exploration-api-worker | aice/code-exploration-api            | Background worker process for the API service that handles asynchronous tasks such as LLM processing. Uses the same image as the API service but runs with a different command.                                                                                       |

</details>

## Third-Party Components

<details>
<summary> Expand the section to review all required 3d party components:</summary>

| Component Name | Image                                                | Description                                                                                                                                                               |
|----------------|------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| neo4j          | neo4j:5.26.3                                         | Graph database used to store and query the code knowledge graph. Configured with APOC and Graph Data Science plugins for advanced graph operations.                       |
| elasticsearch  | docker.elastic.co/elasticsearch/elasticsearch:8.18.1 | Search engine used for full-text searching of code and related metadata. Provides powerful search capabilities across the codebase.                                       |
| redis          | redis:latest                                         | In-memory data store used for caching, session management, and as a message broker for the task queue system. Facilitates communication between API and worker processes. |

</details>

## Container Resource Requirements

<details>
  <summary><strong>Click to expand resource requirements table</strong></summary>

  <table>
    <thead>
      <tr>
        <th>Component Name</th>
        <th>Replicas</th>
        <th>Memory</th>
        <th>CPU (cores)</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>code-exploration-ui</td>
        <td>1</td>
        <td>256Mi</td>
        <td>0.1</td>
      </tr>
      <tr>
        <td>code-analysis-datasource</td>
        <td>1</td>
        <td>4Gi</td>
        <td>2.0</td>
      </tr>
      <tr>
        <td>code-exploration-api</td>
        <td>1</td>
        <td>4Gi</td>
        <td>2.0</td>
      </tr>
      <tr>
        <td>code-exploration-api-worker</td>
        <td>1</td>
        <td>4Gi</td>
        <td>2.0</td>
      </tr>
      <tr>
        <td>neo4j</td>
        <td>1</td>
        <td>16Gi</td>
        <td>2.0</td>
      </tr>
      <tr>
        <td>elasticsearch</td>
        <td>1</td>
        <td>8Gi</td>
        <td>2.0</td>
      </tr>
      <tr>
        <td>elasticvue</td>
        <td>1</td>
        <td>512Mi</td>
        <td>0.2</td>
      </tr>
      <tr>
        <td>redis</td>
        <td>1</td>
        <td>2Gi</td>
        <td>0.5</td>
      </tr>
      <tr>
        <td>postgres</td>
        <td>1</td>
        <td>1Gi</td>
        <td>0.5</td>
      </tr>
    </tbody>
  </table>
</details>

## Codemie Additional Setup

In order to deploy **AICE (AI Code Exploration) add-on** you need to follow additional steps after
platform is installed.

### Add additional resources

Add more nodes for your Kubernetes cluster by changing configuration
in the [deployment.conf](../../terraform-scripts/deployment.conf).

For example, instance type `c5.2xlarge` has `8 vCPUs` and `16 GB RAM`. That
means you need add at least `4` to `TF_VAR_demand_max_nodes_count` and
`TF_VAR_demand_desired_nodes_count`.

> You need to re-run [terraform.sh](../../terraform-scripts/terraform.sh) in
> order to apply new changes.

### Create a new OpenID Client in Keycloak (CHANGE IT)

**TestMate add-on** uses AI/Run&trade; Platform API for the integration, so you
need to create a new OpenID Client in Keycloak for it.

It should have the following settings:

- Client ID: `aitestmate`
- To enable Client Credentials flow, enable `Service account roles`.
- Ensure that `codemie` scope is assigned and set as default scope for this
  client.

> The detailed guide on how to create a new OpenID Client in Keycloak can be
> found in the [Keycloak
> documentation](https://www.keycloak.org/docs/latest/server_admin/#proc-creating-oidc-client_server_administration_guide).

Save the client secret for later use in AI TestMate configuration.

# EPAM AI/Run™ AICE (AI Code Exploration) Components Deployment

## Overview

This section describes the process of the main EPAM AI/Run™ AICE (AI Code Exploration) components deployment to the AWS
EKS cluster.

## Configuration Preparation

As an initial step, gather all relevant details and populate the configuration
file [deployment.conf](deployment.conf)

<table>
    <thead>
      <tr>
        <th>Variable name</th>
        <th>Description</th>
        <th>How to obtain</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>IMAGE_REPOSITORY</td>
        <td>AWS ECR repository link</td>
        <td>Will be visible on EPAM AI/Run™ for AWS Migration and Modernization Marketplace page</td>
      </tr>
<tr>
        <td>CODE_EXPLORATION_API_VERSION</td>
        <td>Code Exploration API version</td>
        <td>Can be chosen on EPAM AI/Run™ for AWS Migration and Modernization Marketplace page</td>
      </tr>
<tr>
        <td>CODE_EXPLORATION_UI_VERSION</td>
        <td>Code Exploration UI version</td>
        <td>Can be chosen on EPAM AI/Run™ for AWS Migration and Modernization Marketplace page</td>
      </tr>
<tr>
        <td>CODE_ANALYSIS_DATASOURCE_VERSION</td>
        <td>Code Analysis Datasource version</td>
        <td>Can be chosen on EPAM AI/Run™ for AWS Migration and Modernization Marketplace page</td>
      </tr>
<tr>
        <td>DOMAIN_NAME</td>
        <td>Available wildcard DNS hosted zone in Route53</td>
        <td>The value should be taken from the Route 53 hosted zone created in the AI/Run™ Platform installation steps</td>
      </tr>
<tr>
        <td>LLM_AWS_REGION_NAME</td>
        <td>AWS region name</td>
        <td>Example: us-east-1</td>
      </tr>
<tr>
        <td>LLM_QUALITY_MODEL_NAME</td>
        <td>Explicit model name for highest quality/performance tier</td>
        <td>Example: anthropic.claude-3-5-sonnet-20241022-v2:0</td>
      </tr>
<tr>
        <td>LLM_BALANCED_MODEL_NAME</td>
        <td>Explicit model name for balanced performance/cost tier</td>
        <td>Example: anthropic.claude-3-sonnet-20240229-v1:0</td>
      </tr>
<tr>
        <td>LLM_EFFICIENCY_MODEL_NAME</td>
        <td>Explicit model name for fastest/lowest cost tier</td>
        <td>Example: anthropic.claude-3-haiku-20240307-v1:0</td>
      </tr>
<tr>
        <td>LLM_EMBEDDING_MODEL_NAME</td>
        <td>Explicit embedding model name</td>
        <td>Example: amazon.titan-embed-text-v1</td>
      </tr>
<tr>
        <td>JWT_PUBLIC_KEY</td>
        <td>JWT public key for authorization and authentication</td>
        <td>Obtain the public key from the Keycloak Admin Console of your AI/Run™ Platform installation</td>
      </tr>
<tr>
        <td colspan="3">Terraform settings</td>        
      </tr>
<tr>
        <td>TF_VAR_platform_name</td>
        <td>Planform name, usual 'codemie'</td>
        <td>Same value as 'TF_VAR_platform_name' in AI/Run Platform deployment configuration</td>
      </tr>
<tr>
<tr>
        <td>AWS_REGIONS</td>
        <td>AWS region</td>
        <td>Example: us-east-1</td>
      </tr>
<tr>
        <td>BACKEND_BUCKET_NAME</td>
        <td>S3 bucket name that uses for Terraform state synchronization</td>
        <td>AI/Run™ Platform installation provides this value under the 'Terraform state will be stored in'</td>
      </tr>
<tr>
        <td>BACKEND_LOCK_DYNAMODB_TABLE</td>
        <td>Lock DynamoDB Table</td>
        <td>AI/Run™ Platform installation provides this value under the 'Terraform state will be stored in'</td>
      </tr>
<tr>
        <td>AWS_DEPLOYER_ROLE_ARN</td>
        <td>IAM Deployer role ARN</td>
        <td>AI/Run™ Platform installation provides this value under the 'Following role will be used for env creation:'</td>
      </tr>

</tbody>
</table>

<details>
<summary>How to obtain the public key from Keycloak Admin Console</summary>

- Log in to the Keycloak Admin Console.
- Select your realm from the left sidebar.
- Go to **Realm Settings**.
- Open the **Keys** tab.
- Find the key with the algorithm (e.g., RS256) used for token signing.
- Click on the key to view its details.
- Copy the **Public Key** value displayed.

Save this public key as a `.pem` file in the `../helm-scripts` folder and set its path in the `JWT_PUBLIC_KEY` setting.

</details>

## There are two options for deploying the system:

## 1. Scripted Components Installation

Use the provided script to deploy all components of the system in one step.

1. Make sure that you are in the `deployment/add-ons/aice` folder.

2. Run the following command if using a Unix-like operating system:
   ```bash
   chmod +x deploy.sh

3. Run the script:
    ```bash
   ./deploy.sh

You can find installation logs in the `../logs` folder.

## 2. Manual Components Installation

Deploy each component separately by following the step-by-step instructions.

⚠️ Important: If the previous step has already been completed, please proceed to skip this step.

<details>
<summary>If you prefer to manually deploy step by step, expand this section for more instructions:</summary>

### 1. Amazon RDS Postgresql installation
[Learn more in the documentation](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.CreatingConnecting.PostgreSQL.html)

#### 1.1 Deploy Amazon RDS Postgresql using AWS Console

#### 1.2 Create k8s Secret with Postgresql data:
```bash
kubectl -n aice create secret generic aice-postgresql-secret \
            --from-literal=password="<AWS_RDS_DATABASE_PASSWORD>" \
            --from-literal=user="<AWS_RDS_DATABASE_USER>" \
            --from-literal=host="$<AWS_RDS_HOST>" \
            --from-literal=db="<AWS_RDS_DATABASE_NAME>"
```

### 2. Navigate helm-scripts folder

```bash
  cd ../helm-scripts
```
### 3. Create namespace:
```bash
  kubectl create namespace aice 
```

### 4. Install Redis:

```bash
  helm upgrade --install aice-redis redis/. --namespace aice --values "redis/values.yaml" --wait --timeout 600s --dependency-update
```

### 5. Install Elasticsearch:
```bash
  helm upgrade \
      --install aice-elasticsearch elasticsearch/. \
      --namespace aice \
      --values "elasticsearch/values.yaml" \
      --wait \
      --timeout 600s \
      --dependency-update 
```
### 6. Install Neo4j:
Create s Secret with Neo4j password:
```bash
kubectl -n $namespace create secret generic aice-neo4j-secret \
        --from-literal=username="neo4j" \
        --from-literal=password="<pwd>" \
        --from-literal=auth="neo4j/<pwd>"
```

```bash
  helm upgrade \
      --install aice-neo4j neo4j/. \
      --namespace aice \
      --values "neo4j/values.yaml" \
      --set neo4j.auth.password=<pwd> \
      --wait \
      --timeout 600s \
      --dependency-update 
```
⚠️ Replace '<pwd>' to saved in the Secret.

Copy Neo4j plugins into Pod`s PVS:
```bash
    # dozerdb
    kubectl cp ../artifacts/neo4j/plugins/dozerdb-plugin-5.26.3.0.jar aice-neo4j-0:/plugins -c neo4j -n aice
    kubectl exec aice-neo4j-0 -c neo4j -n aice -- chown neo4j:neo4j /plugins/dozerdb-plugin-5.26.3.0.jar
    
    # apoc
    kubectl cp $SCRIPT_DIR/artifacts/neo4j/plugins/apoc-5.26.3-core.jar aice-neo4j-0:/plugins -c neo4j -n "$namespace"
    kubectl exec aice-neo4j-0 -c neo4j -n aice -- chown neo4j:neo4j /plugins/apoc-5.26.3-core.jar

    # data-science
    kubectl cp $SCRIPT_DIR/artifacts/neo4j/plugins/neo4j-graph-data-science-2.13.4.jar aice-neo4j-0:/plugins -c neo4j -n "$namespace"
    kubectl exec aice-neo4j-0 -c neo4j -n aice -- chown neo4j:neo4j /plugins/neo4j-graph-data-science-2.13.4.jar
```

Restart statefulset for applying plugins:
```bash
  kubectl rollout restart statefulset aice-neo4j -n aice
```

### 7. Install Code Exploration API:
Modify `code-exploration-api/values.yaml`:
- replace %%IMAGE_REPOSITORY%% to AWS ECR repository link.
- replace %%IMAGE_VERSION%% to proper image version.
- replace %%DOMAIN%% to proper domain name.

Install:
```bash
helm upgrade \
      --install aice-code-exploration-api code-exploration-api/. \
      --namespace aice \
      --values "code-exploration-api/values.yaml" \
      --set environment.llmApiKey="<llm_api_key>" \
      --set-file jwtPublicKey.keyData="<jwt_public_key>" \
      --wait \
      --timeout 600s \
      --dependency-update
```
⚠️ replace <llm_api_key> and <jwt_public_key> to proper values

### 8. Install Code Analysis Datasource:
Modify `code-analysis-datasource/values.yaml`:
- replace %%IMAGE_REPOSITORY%% to AWS ECR repository link.
- replace %%IMAGE_VERSION%% to proper image version.
- replace %%DOMAIN%% to proper domain name.

Install:
```bash
helm upgrade \
      --install aice-code-analysis-datasource code-analysis-datasource/. \
      --namespace aice \
      --values "code-analysis-datasource/values.yaml" \
      --wait \
      --timeout 600s \
      --dependency-update
```

### 9. Install Code Exploration UI:
Modify `code-exploration-ui/values.yaml`:
- replace %%IMAGE_REPOSITORY%% to AWS ECR repository link.
- replace %%IMAGE_VERSION%% to proper image version.
- replace %%DOMAIN%% to proper domain name.

Install:
```bash
helm upgrade \
      --install aice-code-exploration-ui code-exploration-ui/. \
      --namespace aice \
      --values "code-exploration-ui/values.yaml" \
      --wait \
      --timeout 600s \
      --dependency-update
```

</details>

