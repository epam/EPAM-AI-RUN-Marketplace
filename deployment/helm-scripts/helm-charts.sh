#!/bin/bash

set -euo pipefail

AWS_RDS_ENABLE=1 # 0 means true for wider compatibility

# Detect the absolute path of the current script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_FILE="$SCRIPT_DIR/logs/codemie_helm_deployment_$(date +%Y-%m-%d-%H%M%S).log"
CODEMIE_NAMESPACE="codemie"

if [ ! -d "$SCRIPT_DIR/logs" ]; then
    mkdir "$SCRIPT_DIR/logs"
fi

###################
# Helper Functions
###################

log_message() {
    local status="$1"
    local message="$2"
    # shellcheck disable=SC2155
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

display_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                 Display this help message"
    echo "Examples:"
    echo "$0 version=0.21.0"
    exit 1
}

check_nsc() {
    if ! hash nsc; then
        log_message "fail" "nsc is not installed"
        log_message "info" "Install nsc by running the following commands:"
        log_message "info" ""
        log_message "info" "curl -sf https://binaries.nats.dev/nats-io/nsc/v2@latest | sh; sudo cp nsc /usr/bin/"
        log_message "info" ""
        exit 1
    fi
}

check_htpasswd() {
    if ! hash htpasswd; then
        log_message "fail" "htpasswd is not installed"
        log_message "info" "Install htpasswd by running the following commands:"
        log_message "info" ""
        log_message "info" "sudo apt-get install apache2-utils"
        log_message "info" ""
        exit 1
    fi
}

check_helm(){
    if ! hash helm &> /dev/null; then
        log_message "fail" "Helm is not installed. Please install Helm to proceed."
        exit 1
    fi
}

verify_inputs() {
    ai_run_version=""
    image_repository=""

    # Parse arguments
    while [[ $# -gt 0 ]]
    do
        case $1 in
            version=*)
                ai_run_version="${1#*=}"
                shift
                ;;
            --rds-enable)
                AWS_RDS_ENABLE=0
                shift
                ;;
            --image-repository)
                image_repository="$2"
                shift 2
                ;;
            *)
                log_message "fail" "Unknown option: $1"
                display_usage
                ;;
        esac
    done

    if [[ -z "$ai_run_version" ]]; then
        log_message "fail" "version is not set."
        display_usage
    fi

    if [[ -z "$image_repository" ]]; then
        log_message "fail" "image repository is not set."
        display_usage
    fi
}

check_and_create_namespace() {
    local namespace=$1

    # Check if the namespace exists
    if kubectl get namespace "$namespace" > /dev/null 2>&1; then
        log_message "info" "Namespace '$namespace' already exists."
    else
        # Create the namespace
        log_message "info" "Namespace '$namespace' does not exist. Creating..."

        if kubectl create namespace "$namespace" > /dev/null 2>&1; then
            log_message "success" "Namespace '$namespace' created successfully."
        else
            log_message "fail" "Failed to create namespace '$namespace'."
            exit 1
        fi
    fi
}

check_k8s_secret_exists() {
    local namespace="$1"
    local secret_name="$2"

    if kubectl get secret "$secret_name" -n "$namespace" > /dev/null 2>&1; then
        log_message "info" "Secret '$secret_name' exists in namespace '$namespace'."
        return 0
    else
        log_message "info" "Secret '$secret_name' does not exist in namespace '$namespace'."
        return 1
    fi
}

create_docker_registry_secret() {
    local namespace="$1"
    local secret_name="$2"

    key_path="$SCRIPT_DIR/key.json"
    if [ -f "$key_path" ]; then
        log_message "info" "The key.json file exists."
    else
        log_message "fail" "The key.json file does not exist."
        exit 1
    fi

    log_message "info" "Creating secret '${secret_name}' in namespace '${namespace}'..."
    kubectl create secret docker-registry "${secret_name}" \
      --docker-server=https://europe-west3-docker.pkg.dev \
      --docker-email=gsa-to-gcr@or2-msq-epmd-edp-anthos-t1iylu.iam.gserviceaccount.com \
      --docker-username=_json_key \
      --docker-password="$(cat key.json)" \
      --namespace "${namespace}" > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Secret '${secret_name}' created successfully."
    else
        log_message "fail" "Failed to create secret '${secret_name}'."
        exit 1
    fi
}

check_env_vars() {
    local missing_vars=0

    for var in "$@"; do
        if [ -z "${!var:-}" ]; then
            log_message "warn" "Environment variable $var is not set."
            missing_vars=1
        fi
    done

    return $missing_vars
}

replace_domain_placeholders() {
    local values_file="$1"
    local domain_value="$2"
    local backup_file="${values_file}.backup"

    if [[ -f "$backup_file" ]]; then
        log_message "info" "Restoring ${values_file} from backup"
        mv "$backup_file" "$values_file"
        log_message "info" "Deleting leftover backup file"
        rm -f "$backup_file"
    fi

    log_message "info" "Replacing placeholders with values"
    if [[ "$OSTYPE" == "darwin"* ]]; then
           # macOS/BSD sed syntax (requires backup extension)
        sed -i '.backup' "s|%%DOMAIN%%|${domain_value}|g" "${values_file}"
    else
           # GNU sed (Linux syntax; doesn't require extension)
        sed -i.backup "s|%%DOMAIN%%|${domain_value}|g" "${values_file}"
    fi
}

replace_aws_placeholders() {
    local values_file="$1"
    local aws_default_region="$2"
    local aws_eks_role_arn="$3"
    local aws_kms_key_id="$4"
    local aws_s3_bucket_name="$5"
    local aws_s3_region="$6"

    local backup_file="${values_file}.aws.backup"

    if [[ -f "$backup_file" ]]; then
        log_message "info" "Restoring ${values_file} from backup"
        mv "$backup_file" "$values_file"
        log_message "info" "Deleting leftover backup file"
        rm -f "$backup_file"
    fi

    # macOS vs Linux 'sed' syntax compatibility
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS/BSD sed: create backup file with extension
        sed -i '.aws.backup' "
            s|%%AWS_DEFAULT_REGION%%|${aws_default_region}|g;
            s|%%EKS_AWS_ROLE_ARN%%|${aws_eks_role_arn}|g;
            s|%%AWS_KMS_KEY_ID%%|${aws_kms_key_id}|g;
            s|%%AWS_S3_BUCKET_NAME%%|${aws_s3_bucket_name}|g;
            s|%%AWS_S3_REGION%%|${aws_s3_region}|g;
        " "${values_file}"
    else
        # GNU sed (Linux): create backup file with .aws.backup extension
        sed -i.aws.backup "
            s|%%AWS_DEFAULT_REGION%%|${aws_default_region}|g;
            s|%%EKS_AWS_ROLE_ARN%%|${aws_eks_role_arn}|g;
            s|%%AWS_KMS_KEY_ID%%|${aws_kms_key_id}|g;
            s|%%AWS_S3_BUCKET_NAME%%|${aws_s3_bucket_name}|g;
            s|%%AWS_S3_REGION%%|${aws_s3_region}|g;
        " "${values_file}"
    fi

    log_message "info" "Placeholders replaced successfully in ${values_file}"
}

replace_image_repository_placeholders() {
    local values_file="$1"
    local image_repository="$2"
    local backup_file="${values_file}.img.backup"

    if [[ -f "$backup_file" ]]; then
        log_message "info" "Restoring ${values_file} from backup"
        mv "$backup_file" "$values_file"
        log_message "info" "Deleting leftover backup file"
        rm -f "$backup_file"
    fi

    log_message "info" "Replacing placeholders with values"
    if [[ "$OSTYPE" == "darwin"* ]]; then
           # macOS/BSD sed syntax (requires backup extension)
        sed -i '.img.backup' "s|%%IMAGE_REPOSITORY%%|${image_repository}|g" "${values_file}"
    else
           # GNU sed (Linux syntax; doesn't require extension)
        sed -i.img.backup "s|%%IMAGE_REPOSITORY%%|${image_repository}|g" "${values_file}"
    fi
}

load_deployment_env() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")/terraform-scripts"
  OUTPUT_FILE="$TERRAFORM_DIR/deployment_outputs.env"

  if [ -f "$OUTPUT_FILE" ]; then
      log_message "info" "Loading outputs from $OUTPUT_FILE"
      set -a
      source "$OUTPUT_FILE"
      set +a
  fi
}

load_configuration() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")/terraform-scripts"
  OUTPUT_FILE="$TERRAFORM_DIR/deployment.conf"

  if [ -f "$OUTPUT_FILE" ]; then
      log_message "info" "Loading configuration from $OUTPUT_FILE"
      set -a
      source "$OUTPUT_FILE"
      set +a
  else
      log_message "fail" "Configuration file $OUTPUT_FILE not found"
      echo "Please create a configuration file or specify an alternate file with --config-file"
      exit 1
  fi
}

configure_kubectl() {
    log_message "info" "Configuring kubectl with current cluster ..."
    aws eks update-kubeconfig --region ${TF_VAR_region} --name ${TF_VAR_platform_name}
}

print_summary() {
    log_message "info" "Deployment Summary"
    log_message "info" "=================="
    log_message "info" "Keycloak: https://keycloak.${TF_VAR_platform_domain_name}/auth/admin"
    log_message "info" "Keycloak User: $(kubectl get secret keycloak-admin -n security -o jsonpath="{.data.username}" | base64 --decode)"
    log_message "info" "Keycloak Password: $(kubectl get secret keycloak-admin -n security -o jsonpath="{.data.password}" | base64 --decode)"
    log_message "info" "=================="
    log_message "info" "All deployments completed successfully."
    log_message "info" "Deployment outputs have been saved to deployment_outputs.env"
    log_message "info" "Log file: $LOG_FILE"
}

###################
# Deployment Steps
###################

deploy_codemie_docker_registry_secret() {
    local namespace="$1"
    local secret_name="$2"

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$secret_name"; then
        create_docker_registry_secret "$namespace" "$secret_name"
    fi
}

deploy_nginx_ingress_controller() {
    local namespace="ingress-nginx"
    local cloud_provider="$1"

    log_message "info" "Starting Nginx Ingress Controller deployment"

    check_and_create_namespace "$namespace"

    log_message "info" "Deploying Nginx Ingress Controller Helm Chart ..."
    helm upgrade \
      --install ingress-nginx ingress-nginx/. \
      --namespace "$namespace" \
      --values "ingress-nginx/values-${cloud_provider}.yaml" \
      --wait \
      --timeout 900s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Nginx Ingress Controller deployment completed"
    else
        log_message "fail" "Failed to deploy Nginx Ingress Controller."
        exit 1
    fi

    log_message "success" "Nginx Ingress Controller configuration completed"
}

deploy_storage_class() {
  log_message "info" "Deploying Storage Class ..."
  kubectl apply -f "storage-class/storageclass-aws-gp3.yaml" > /dev/null
}

deploy_elasticsearch() {
  local namespace="elastic"
  local secret_name="elasticsearch-master-credentials"
  local cloud_provider="$1"

  log_message "info" "Starting Elasticsearch deployment"

  check_and_create_namespace "$namespace"

  if ! check_k8s_secret_exists "$namespace" "$secret_name"; then
      kubectl -n $namespace create secret generic $secret_name \
      --from-literal=username=elastic \
      --from-literal=password="$(openssl rand -base64 12 | tr -d '/+=')" \
      --type=Opaque \
      --dry-run=client -o yaml | kubectl apply -f - > /dev/null
  fi

  log_message "info" "Deploying Elasticsearch Helm Chart ..."
  helm upgrade \
    --install elastic elasticsearch/. \
    --namespace "$namespace" \
    --values "elasticsearch/values-${cloud_provider}.yaml" \
    --wait \
    --timeout 900s \
    --dependency-update > /dev/null

  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    log_message "success" "Elasticsearch deployment completed"
  else
    log_message "fail" "Failed to deploy Elasticsearch."
    exit 1
  fi
}

deploy_kibana() {
    local namespace="elastic"
    local cloud_provider="$1"
    local values_file="kibana/values-${cloud_provider}.yaml"
    local domain_value="$2"

    log_message "info" "Starting Kibana deployment"

    if check_k8s_secret_exists "$namespace" "kibana-kibana-es-token"; then
        kubectl delete secret kibana-kibana-es-token -n $namespace > /dev/null 2>&1
        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret 'kibana-kibana-es-token' removed successfully."
        else
            log_message "fail" "Failed to remove kibana-kibana-es-token secret."
            exit 1
        fi
    fi

    replace_domain_placeholders "${values_file}" "${domain_value}"

    log_message "info" "Deploying Kibana Helm Chart ..."
    helm upgrade \
      --install kibana kibana/. \
      --namespace "$namespace" \
      --values "${values_file}" \
      --wait \
      --timeout 900s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Kibana deployment completed"
        if [[ "$cloud_provider" == "azure" ]]; then
            log_message "info" "Kibana is available at: http://codemie.private.lab.com/kibana"
        elif [[ "$cloud_provider" == "aws" ]]; then
            log_message "info" "Kibana is available at: https://kibana.${domain_value}"
        fi
    else
        log_message "fail" "Failed to deploy Kibana."
        exit 1
    fi
}

deploy_keycloak_operator() {
    local namespace="security"
    local secret_name="keycloak-admin"

    log_message "info" "Starting Keycloak Operator deployment"

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$secret_name"; then
        kubectl -n "$namespace" create secret generic "$secret_name" \
          --from-literal=username=admin \
          --from-literal=password="$(openssl rand -base64 12)" \
          --type=Opaque \
          --dry-run=client -o yaml | kubectl apply -f - > /dev/null

        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret '$secret_name' created successfully."
        else
            log_message "fail" "Failed to create secret '$secret_name'."
            exit 1
        fi
    fi



    log_message "info" "Deploying Keycloak Operator Helm Chart ..."
    helm upgrade --install keycloak-operator keycloak-operator-helm/. \
      --namespace "$namespace" \
      --values keycloak-operator-helm/values.yaml \
      --wait \
      --timeout 900s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Keycloak Operator deployment completed"
    else
        log_message "fail" "Failed to deploy Keycloak Operator."
        exit 1
    fi
}

deploy_postgres_operator() {
    local namespace="postgres-operator"

    log_message "info" "Starting Postgres Operator deployment"

    check_and_create_namespace "$namespace"

    log_message "info" "Deploying Postgres Operator Helm Chart ..."
    helm upgrade --install postgres-operator postgres-operator-helm/. \
      --namespace "$namespace" \
      --create-namespace \
      --wait \
      --timeout 900s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Postgres Operator deployment completed"
    else
        log_message "fail" "Failed to deploy Postgres Operator."
        exit 1
    fi
}

deploy_keycloak() {
    local namespace="security"
    local cloud_provider="$1"
    local values_file="keycloak-helm/values-${cloud_provider}.yaml"
    local domain_value="$2"

    log_message "info" "Starting Keycloak deployment"

    check_and_create_namespace "$namespace"
    replace_domain_placeholders "$values_file" "$domain_value"

    log_message "info" "Deploying Keycloak Helm Chart ..."
    helm upgrade --install keycloak keycloak-helm/. \
      --namespace "$namespace" \
      --values "${values_file}" \
      --wait \
      --timeout 900s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Keycloak deployment completed"
        if [[ "$cloud_provider" == "azure" ]]; then
            log_message "info" "Keycloak console is available at: https://codemie.private.lab.com/keycloak/admin"
        elif [[ "$cloud_provider" == "aws" ]]; then
            log_message "info" "Keycloak is available at: https://keycloak.${domain_value}/auth/admin"
        fi
    else
        log_message "fail" "Failed to deploy Keycloak."
        exit 1
    fi
}

deploy_oauth2_proxy() {
    local namespace="oauth2-proxy"
    local cloud_provider="$1"
    local secret_name="oauth2-proxy"
    local values_file="oauth2-proxy/values-${cloud_provider}.yaml"
    local domain_value="$2"

    log_message "info" "Starting OAuth2 Proxy deployment"

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$secret_name"; then
        kubectl create secret generic "$secret_name" \
          --namespace="$namespace" \
          --from-literal=client-id="codemie" \
          --from-literal=client-secret="$(openssl rand -base64 12)" \
          --from-literal=cookie-secret="$(dd if=/dev/urandom bs=32 count=1 2>/dev/null | base64 | tr -d -- '\n' | tr -- '+/' '-_' ; echo)" \
          --type=Opaque > /dev/null

        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret '$secret_name' created successfully."
        else
            log_message "fail" "Failed to create secret '$secret_name'."
            exit 1
        fi
    fi

    if ! check_k8s_secret_exists "$namespace" "keycloak-admin"; then
        kubectl get secret keycloak-admin -n security -o yaml | sed '/namespace:/d' | kubectl apply -n "$namespace" -f - > /dev/null
        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret 'keycloak-admin' created successfully."
        else
            log_message "fail" "Failed to create secret 'keycloak-admin'."
            exit 1
        fi
    fi

    replace_domain_placeholders "$values_file" "$domain_value"

    log_message "info" "Deploying OAuth2 Proxy Helm Chart ..."
    helm upgrade --install oauth2-proxy oauth2-proxy/. \
      --namespace "$namespace" \
      --values "${values_file}" \
      --wait \
      --timeout 900s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "OAuth2 Proxy deployment completed"
    else
        log_message "fail" "Failed to deploy OAuth2 Proxy."
        exit 1
    fi
}

deploy_fluent_bit() {
    local namespace="fluent-bit"
    local cloud_provider="$1"
    local values_file="./fluent-bit/values-${cloud_provider}.yaml"

    log_message "info" "Starting FluentBit deployment"
    check_and_create_namespace "$namespace"

    helm upgrade --install fluent-bit fluent-bit/. \
      --namespace "$namespace" \
      -f "${values_file}" \
      --wait \
      --timeout 180s > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "FluentBit deployment completed"
    else
        log_message "fail" "Failed to deploy FluentBit."
        exit 1
    fi

}

deploy_codemie_ui() {
    local namespace="codemie"
    local cloud_provider="$1"
    local domain_value="$2"
    local values_file="./codemie-ui/values-${cloud_provider}.yaml"
    local chart_file="./codemie-ui/Chart.yaml"
    local image_repository="$3"
    local ai_run_version="$4"

    log_message "info" "Starting AI/Run UI deployment"

    check_and_create_namespace "$namespace"

    replace_domain_placeholders "$values_file" "$domain_value"
    replace_image_repository_placeholders "${values_file}" "${image_repository}"
    replace_image_repository_placeholders "${chart_file}" "${image_repository}"

    log_message "info" "Deploying AI/Run UI Helm Chart ..."
    helm upgrade --install codemie-ui codemie-ui/. \
      --version "${ai_run_version}" \
      --namespace "$namespace" \
      -f "${values_file}" \
      --wait \
      --timeout 180s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "AI/Run UI deployment completed"
    else
        log_message "fail" "Failed to deploy AI/Run UI."
        exit 1
    fi
}

deploy_codemie_api() {
    local namespace="codemie"
    local cloud_provider="$1"
    local domain_value="$2"
    local values_file="./codemie-api/values-${cloud_provider}.yaml"
    local chart_file="./codemie-api/values-${cloud_provider}.yaml"
    local image_repository="$3"
    local ai_run_version="$4"

    log_message "info" "Starting AI/Run API deployment"

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "elasticsearch-master-credentials"; then
        kubectl get secret elasticsearch-master-credentials -n elastic -o yaml | sed '/namespace:/d' | kubectl apply -n "$namespace" -f - > /dev/null
        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret 'elasticsearch-master-credentials' created successfully."
        else
            log_message "fail" "Failed to create secret 'elasticsearch-master-credentials'."
            exit 1
        fi
    fi

    replace_domain_placeholders "$values_file" "$domain_value"
    replace_aws_placeholders "$values_file" "${AWS_DEFAULT_REGION}" "${EKS_AWS_ROLE_ARN}" "${AWS_KMS_KEY_ID}" "${AWS_S3_BUCKET_NAME}" "${AWS_DEFAULT_REGION}"
    replace_image_repository_placeholders "${values_file}" "${image_repository}"
    replace_image_repository_placeholders "${chart_file}" "${image_repository}"

    log_message "info" "Deploying AI/Run API Helm Chart ..."
    helm upgrade --install codemie-api codemie-api/. \
      --version "${ai_run_version}" \
      --namespace "$namespace" \
      -f "${values_file}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "AI/Run API deployment completed"
    else
        log_message "fail" "Failed to deploy AI/Run API."
        exit 1
    fi
}

deploy_nats() {
    local cloud_provider="$1"
    local namespace="codemie"
    local secret_name="codemie-nats-secrets"

    log_message "info" "Starting NATS deployment"

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$secret_name"; then
        log_message "info" "Creating secret '$secret_name' in namespace '$namespace'..."
        callout_password=$(openssl rand -hex 16)
        codemie_password=$(openssl rand -hex 16)
        # shellcheck disable=SC2016
        bcrypted_callout_password=$(htpasswd -bnBC 10 "" "${callout_password}" | tr -d ':\n' | sed 's/$2y/$2a/')
        # shellcheck disable=SC2016
        bcrypted_codemie_password=$(htpasswd -bnBC 10 "" "${codemie_password}" | tr -d ':\n' | sed 's/$2y/$2a/')

        ISSUER_NKEY=""
        ISSUER_NSEED=""
        output_nkey_account=$(nsc generate nkey --account 2>&1)
        while IFS= read -r line; do
            if [[ $line == A* ]]; then
                ISSUER_NKEY="$line"
            elif [[ $line == S* ]]; then
                ISSUER_NSEED="$line"
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

        # Set NATS_URL based on cloud provider
        local nats_url
        if [[ "$cloud_provider" == "aws" ]]; then
            nats_url="nats://codemie-nats:4222"
        else
            nats_url="nats://codemie-nats:443"
        fi

        kubectl -n "$namespace" create secret generic "$secret_name" \
          --from-literal=NATS_URL="$nats_url" \
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
          --type=Opaque > /dev/null

        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret '$secret_name' created successfully."
        else
            log_message "fail" "Failed to create secret '$secret_name'."
            exit 1
        fi
    fi

    log_message "info" "Deploying NATS Helm Chart ..."
    helm repo add nats https://nats-io.github.io/k8s/helm/charts/ > /dev/null
    helm repo update nats > /dev/null
    helm upgrade --install codemie-nats nats/nats --version 1.2.6 \
      --namespace $namespace --values "./codemie-nats/values-${cloud_provider}.yaml" \
      --wait --timeout 900s > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "NATS deployment completed"
    else
        log_message "fail" "Failed to deploy NATS."
        exit 1
    fi
}

deploy_codemie_nats_callout() {
    local cloud_provider="$1"
    local ai_run_version="$2"
    local image_repository="$3"
    local values_file="codemie-nats-auth-callout/values-${cloud_provider}.yaml"
    local chart_file="codemie-nats-auth-callout/Chart.yaml"

    local namespace="codemie"
    local secret_name="codemie-nats-secrets"

    log_message "info" "Starting CodeMie NATS Callout deployment."

    replace_image_repository_placeholders "${values_file}" "${image_repository}"
    replace_image_repository_placeholders "${chart_file}" "${image_repository}"

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$secret_name"; then
        log_message "fail" "Failed to get secret '$secret_name'."
        exit 1
    fi

    log_message "info" "Deploying CodeMie NATS Callout Helm Chart ..."
    helm upgrade --install codemie-nats-auth-callout codemie-nats-auth-callout/. \
      --version "${ai_run_version}" \
      --namespace "$namespace" \
      -f "${values_file}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "CodeMie NATS Callout deployment completed."
    else
        log_message "fail" "Failed to deploy CodeMie NATS Callout."
        exit 1
    fi
}

deploy_codemie_mcp_connect_service() {
    local cloud_provider="$1"
    local ai_run_version="$2"
    local image_repository="$3"
    local values_file="./codemie-mcp-connect-service/values.yaml"
    local chart_file="./codemie-mcp-connect-service/Chart.yaml"

    local namespace="codemie"

    log_message "info" "Starting CodeMie MCP Connect Service deployment."

    replace_image_repository_placeholders "${values_file}" "${image_repository}"
    replace_image_repository_placeholders "${chart_file}" "${image_repository}"

    check_and_create_namespace "$namespace"

    log_message "info" "Deploying CodeMie MCP Connect Service Helm Chart ..."
    helm upgrade --install codemie-mcp-connect-service codemie-mcp-connect-service/. \
      --version "${ai_run_version}" \
      --namespace "$namespace" \
      -f "${values_file}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "CodeMie MCP Connect Service deployment completed."
    else
        log_message "fail" "Failed to deploy CodeMie MCP Connect Service."
        exit 1
    fi
}

deploy_mermaid_server() {
    local cloud_provider="$1"
    local ai_run_version="$2"
    local image_repository="$3"
    local values_file="./mermaid-server/values.yaml"
    local chart_file="./mermaid-server/Chart.yaml"

    local namespace="codemie"

    log_message "info" "Starting Mermaid Server deployment."
    replace_image_repository_placeholders "${values_file}" "${image_repository}"
    replace_image_repository_placeholders "${chart_file}" "${image_repository}"

    check_and_create_namespace "$namespace"

    log_message "info" "Deploying Mermaid Server Helm Chart ..."
    helm upgrade --install mermaid-server mermaid-server/. \
      --version "${ai_run_version}" \
      --namespace "$namespace" \
      -f "${values_file}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Mermaid Server deployment completed."
    else
        log_message "fail" "Failed to deploy Mermaid Server."
    fi
}

deploy_codemie_postgresql() {
    local cloud_provider="$1"
    local namespace="codemie"
    local postgres_secret_name="codemie-postgresql"

    log_message "info" "Starting CodeMie PostgreSQL deployment."

    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$postgres_secret_name"; then
        kubectl -n $namespace create secret generic $postgres_secret_name \
            --from-literal=password="$(openssl rand -base64 12)" \
            --from-literal=postgres-password="$(openssl rand -base64 12)" \
            --from-literal=user="admin" \
            --from-literal=db-url="codemie-postgresql" \
            --from-literal=db-name="codemie" > /dev/null
        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret '$postgres_secret_name' created successfully."
        else
            log_message "fail" "Failed to create secret '$postgres_secret_name'."
            exit 1
        fi
    fi

    log_message "info" "Deploying CodeMie PostgreSQL Helm Chart ..."
    helm upgrade --install codemie-postgresql "bitnami/postgresql" \
      --version "16.7.4" \
      --namespace "$namespace" \
      -f "./codemie-postgresql/values-${cloud_provider}.yaml" \
      --wait \
      --timeout 600s > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "CodeMie PostgreSQL deployment completed."
    else
        log_message "fail" "Failed to deploy CodeMie PostgreSQL."
    fi
}

deploy_codemie_aws_rds() {
    local namespace="codemie"
    local postgres_secret_name="codemie-postgresql"

    log_message "info" "Starting CodeMie PostgreSQL deployment."
    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$postgres_secret_name"; then
        kubectl -n $namespace create secret generic $postgres_secret_name \
            --from-literal=password="${AWS_RDS_DATABASE_PASSWORD}" \
            --from-literal=user="${AWS_RDS_DATABASE_USER}" \
            --from-literal=db-url="${AWS_RDS_ADDRESS}" \
            --from-literal=db-name="${AWS_RDS_DATABASE_NAME}" > /dev/null

        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret '$postgres_secret_name' created successfully."
        else
            log_message "fail" "Failed to create secret '$postgres_secret_name'."
            exit 1
        fi
    fi
}

################
# Main Function
################

main() {
    echo "AI/Run CodeMie Helm Charts Deployment Script"
    echo "================================"

    exec > >(tee -a "$LOG_FILE") 2>&1

    verify_inputs "$@"
    log_message "info" ""
    log_message "info" "version is set to '$ai_run_version'"
    log_message "info" ""
    check_helm
    load_deployment_env
    load_configuration

    check_nsc
    check_htpasswd
    configure_kubectl
    deploy_nginx_ingress_controller "aws"
    deploy_storage_class "aws"
    deploy_elasticsearch "aws"

    deploy_kibana "aws" "${TF_VAR_platform_domain_name}"
    deploy_keycloak_operator
    deploy_postgres_operator
    deploy_keycloak "aws" "${TF_VAR_platform_domain_name}"
    deploy_oauth2_proxy "aws" "${TF_VAR_platform_domain_name}"
    deploy_nats "aws"
    deploy_codemie_nats_callout "aws" "$ai_run_version" "$image_repository"
    deploy_codemie_mcp_connect_service "aws" "$ai_run_version" "$image_repository"
    deploy_mermaid_server "aws" "$ai_run_version" "$image_repository"

    if [ "$AWS_RDS_ENABLE" -eq 0 ]; then
        deploy_codemie_aws_rds
    else
        deploy_codemie_postgresql "aws"
    fi

    deploy_codemie_ui "aws" "${TF_VAR_platform_domain_name}" "$image_repository" "$ai_run_version"
    deploy_codemie_api "aws" "${TF_VAR_platform_domain_name}" "$image_repository" "$ai_run_version"
    print_summary

}

main "$@"
