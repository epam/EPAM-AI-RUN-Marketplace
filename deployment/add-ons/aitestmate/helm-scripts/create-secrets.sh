#!/usr/bin/env bash

NAMESPACE="$1"

namespace-p() {
  kubectl get namespace "$NAMESPACE" -o name &> /dev/null
}

secret-p() {
  local secret_name="$1"

  kubectl get secret "$secret_name" -o name -n "$NAMESPACE" &> /dev/null
}

create-secret() {
    if secret-p "$1"; then
        echo "Secret $1 already exists"
    else
        kubectl --namespace "$NAMESPACE" create secret generic --type Opaque "$@"
    fi
}

if ! namespace-p "$NAMESPACE"; then
    echo "'$NAMESPACE' does not exist"
    exit 1
fi
