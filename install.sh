#!/bin/bash

if [[ -z "$1" ]]; then
  echo "Usage: $0 <namespace>"
  exit 1
fi

NAMESPACE="$1"

helm upgrade "$NAMESPACE-redis"         charts/aitestmate-redis         --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-redis/examples/aws/values.yaml
helm upgrade "$NAMESPACE-rabbitmq"      charts/aitestmate-rabbitmq      --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-rabbitmq/examples/aws/values.yaml
helm upgrade "$NAMESPACE-elasticsearch" charts/aitestmate-elasticsearch --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-elasticsearch/examples/aws/values.yaml
helm upgrade "$NAMESPACE-kibana"        charts/aitestmate-kibana        --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-kibana/examples/aws/values.yaml
helm upgrade "$NAMESPACE-embeddings"    charts/aitestmate-embeddings    --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-embeddings/examples/aws/values.yaml
helm upgrade "$NAMESPACE-migrator"      charts/aitestmate-migrator      --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-migrator/examples/aws/values.yaml
helm upgrade "$NAMESPACE-beat"          charts/aitestmate-beat          --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-beat/examples/aws/values.yaml
helm upgrade "$NAMESPACE-flower"        charts/aitestmate-flower        --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-flower/examples/aws/values.yaml
helm upgrade "$NAMESPACE-sysworker"     charts/aitestmate-sysworker     --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-sysworker/examples/aws/values.yaml
helm upgrade "$NAMESPACE-worker"        charts/aitestmate-worker        --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-worker/examples/aws/values.yaml
helm upgrade "$NAMESPACE-api"           charts/aitestmate-api           --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-api/examples/aws/values.yaml
helm upgrade "$NAMESPACE-nginx"         charts/aitestmate-nginx         --install --namespace "$NAMESPACE" --create-namespace -f charts/aitestmate-nginx/examples/aws/values.yaml
