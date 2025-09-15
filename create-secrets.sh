#!/usr/bin/env bash

NAMESPACE="$1"

namespace-p() {
  local namespace="$1"

  kubectl get namespace "$namespace" -o name &> /dev/null
}

secret-p() {
  local namespace="$1"
  local secret_name="$2"

  kubectl get secret "$secret_name" -o name -n "$namespace" &> /dev/null
}

create-secret() {
    kubectl --namespace "$NAMESPACE" create secret generic --type opaque "$@"
}


if ! namespace-p "$NAMESPACE"; then
    echo "'$NAMESPACE' does not exist"
    exit 1
fi
