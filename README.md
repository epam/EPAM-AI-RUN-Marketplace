# AI TestMate Helm Charts

This provides instructions for installing and configuring `aitestmate` helm
charts. All listed helm charts must be installed into the same namespace, and
each chart can have only one instance per namespace.

Follow the example commands and descriptions below to set up your environment.

## Prerequisites

- [Helm 3.16+](https://helm.sh/) installed on your system
- Kubernetes cluster accessible
- Sufficient cluster permissions to create namespaces and resources

# Installation Instructions

All helm charts must be installed in the **same namespace** (e.g.,
`aitestmate`). Consider `values.yaml` for each charts and corresponding
`examples/` directory.

Pay attention that for some components, like `aitestmate-worker`,
`aitestmate-sysworker`, `aitestmate-api` a service account is created. These
service accounts must be properly annotated with appropriate IAM Role.

Service accounts require permissions to work with LLM API.
For example, with `AmazonBadrock` in AWS.

See an example of [install.sh](./install.sh).

## Deploy aitestmate-elasticsearch

Helm chart provides basic single-node installation of `elasticsearch` 8.x as the database.
You can install elasticsearch stack by yourself and skip this step.

Install `aitestmate-elasticsearch` as the database:

```bash
helm upgrade aitestmate-elasticsearch charts/aitestmate-elasticsearch \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-elasticsearch/examples/aws/values.yaml
```

### (Optional) Deploy aitestmate-kibana

If you require a visualization dashboard for Elasticsearch, install `aitestmate-kibana`.
You can install elasticsearch stack by yourself and skip this step.

```bash
helm upgrade aitestmate-kibana charts/aitestmate-kibana \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-kibana/examples/aws/values.yaml
```
### Deploy aitestmate-redis

Install `aitestmate-redis` as the caching and key-value store:
You can install redis by yourself and skip this step.

```bash
helm upgrade aitestmate-redis charts/aitestmate-redis \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-redis/examples/aws/values.yaml
```

### Deploy aitestmate-rabbitmq

Install `aitestmate-rabbitmq` as the message broker.
You can install rabbitmq by yourself and skip this step.

```bash
helm upgrade aitestmate-rabbitmq charts/aitestmate-rabbitmq \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-rabbitmq/examples/aws/values.yaml
```

### Deploy aitestmate-embeddings

Install `aitestmate-embeddings`, which provides the embeddings service:

```bash
helm upgrade aitestmate-embeddings charts/aitestmate-embeddings \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-embeddings/examples/aws/values.yaml
```

### Deploy aitestmate-migrator

Before deploying core application components, run the `aitestmate-migrator` to
seed or migrate the database:

```bash
helm upgrade aitestmate-migrator charts/aitestmate-migrator \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-migrator/examples/aws/values.yaml
```

Ensure the migrator job has completed successfully before proceeding to the next components.

### Deploy aitestmate-beat

Install `aitestmate-beat`, which serves as an internal cron scheduler for periodic tasks:

```bash
helm upgrade aitestmate-beat charts/aitestmate-beat \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-beat/examples/aws/values.yaml
```

### (Optional) Deploy aitestmate-flower

If you need a UI to view Celery tasks, install `aitestmate-flower`:

```bash
helm upgrade aitestmate-flower charts/aitestmate-flower \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-flower/examples/aws/values.yaml
```

### Deploy aitestmate-sysworker

Optional, but recommended. Install `aitestmate-sysworker`, a dedicted worker
to process internal system tasks:

```bash
helm upgrade aitestmate-sysworker charts/aitestmate-sysworker \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-sysworker/examples/aws/values.yaml
```

There is enough 1 instance of the `aitestmate-sysworker`.

### Deploy aitestmate-worker

Install `aitestmate-worker` to handle heavy application tasks like builds and tests:

```bash
helm upgrade aitestmate-worker charts/aitestmate-worker \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-worker/examples/aws/values.yaml
```

By default 2 workers will be deployed. You can scale number of workers by
setting `replicaCount` to a higher values.

### Deploy aitestmate-api

Install `aitestmate-api`, which provides the main API endpoint of the application:

```bash
helm upgrade aitestmate-api charts/aitestmate-api \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-api/examples/aws/values.yaml
```

### Deploy aitestmate-nginx

Finally, install `aitestmate-nginx`, which serves both the frontend and proxies API requests:

```bash
helm upgrade aitestmate-nginx charts/aitestmate-nginx \
     --install --namespace aitestmate --create-namespace \
     -f charts/aitestmate-nginx/examples/aws/values.yaml
```
