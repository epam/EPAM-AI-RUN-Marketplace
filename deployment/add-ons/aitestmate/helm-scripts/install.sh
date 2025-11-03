#!/usr/bin/env bash

# Relative path is enough here
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <namespace> <container-registry> [version]"
    echo "  namespace: required, kubernetes namespace, e.g. aitestmate"
    echo "  container-registry: required, registry with aitestmate images, e.g. 000000000000.dkr.ecr.us-east-1.amazonaws.com"
    echo "  version: optional, override version, e.g. 2.2.1-aws"
    exit 1
fi

NAMESPACE="$1"
CONTAINER_REGISTRY="$2"
IMAGE_TAG="$3"

function helm-upgrade() {
    local name="$1"; shift

    helm upgrade "$NAMESPACE-$name" "$SCRIPT_DIR/charts/aitestmate-$name" \
         --install --namespace "$NAMESPACE" --create-namespace \
         ${CONTAINER_REGISTRY:+--set image.repository=$CONTAINER_REGISTRY/epam-systems/add-ons/aitestmate/$name} \
         ${IMAGE_TAG:+--set image.tag=$IMAGE_TAG} \
         "$@"
}

helm-upgrade redis         -f "$SCRIPT_DIR/charts/aitestmate-redis/examples/aws/values.yaml"
helm-upgrade rabbitmq      -f "$SCRIPT_DIR/charts/aitestmate-rabbitmq/examples/aws/values.yaml"
helm-upgrade elasticsearch -f "$SCRIPT_DIR/charts/aitestmate-elasticsearch/examples/aws/values.yaml"
helm-upgrade kibana        -f "$SCRIPT_DIR/charts/aitestmate-kibana/examples/aws/values.yaml"
helm-upgrade embeddings    -f "$SCRIPT_DIR/charts/aitestmate-embeddings/examples/aws/values.yaml"
helm-upgrade migrator      -f "$SCRIPT_DIR/charts/aitestmate-migrator/examples/aws/values.yaml"
helm-upgrade beat          -f "$SCRIPT_DIR/charts/aitestmate-beat/examples/aws/values.yaml"
helm-upgrade flower        -f "$SCRIPT_DIR/charts/aitestmate-flower/examples/aws/values.yaml"
helm-upgrade sysworker     -f "$SCRIPT_DIR/charts/aitestmate-sysworker/examples/aws/values.yaml"
helm-upgrade worker        -f "$SCRIPT_DIR/charts/aitestmate-worker/examples/aws/values.yaml"
helm-upgrade api           -f "$SCRIPT_DIR/charts/aitestmate-api/examples/aws/values.yaml"
helm-upgrade nginx         -f "$SCRIPT_DIR/charts/aitestmate-nginx/examples/aws/values.yaml"
