#!/usr/bin/env  bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_FILE="$SCRIPT_DIR/logs/aice_helm_deployment_$(date +%Y-%m-%d-%H%M%S).log"

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

verify_configs() {

    if [[ -z "${LLM_AWS_REGION_NAME}" ]]; then
        log_message "fail" "LLM_AWS_REGION_NAME is not set."
        exit 1
    fi

    if [[ -z "${DOMAIN_NAME}" ]]; then
        log_message "fail" "DOMAIN_NAME is not set."
        exit 1
    fi

    if [[ -z "${IMAGE_REPOSITORY}" ]]; then
        log_message "fail" "IMAGE_REPOSITORY is not set."
        exit 1
    fi

    if [[ -z "${CODE_EXPLORATION_API_VERSION}" ]]; then
        log_message "fail" "CODE_EXPLORATION_API_VERSION is not set."
        exit 1
    fi

    if [[ -z "${DOMAIN_NAME}" ]]; then
        log_message "fail" "DOMAIN_NAME is not set."
        exit 1
    fi

    if [[ -z "${JWT_PUBLIC_KEY}" ]]; then
        log_message "fail" "JWT_PUBLIC_KEY is not set."
        exit 1
    fi

    if [[ -z "${AWS_RDS_ADDRESS}" ]]; then
        log_message "fail" "AWS_RDS_ADDRESS is not set."
        exit 1
    fi

    if [[ -z "${AWS_RDS_DATABASE_NAME}" ]]; then
        log_message "fail" "AWS_RDS_DATABASE_NAME is not set."
        exit 1
    fi

    if [[ -z "${AWS_RDS_DATABASE_USER}" ]]; then
        log_message "fail" "AWS_RDS_DATABASE_USER is not set."
        exit 1
    fi

    if [[ -z "${AWS_RDS_DATABASE_PASSWORD}" ]]; then
        log_message "fail" "AWS_RDS_DATABASE_PASSWORD is not set."
        exit 1
    fi
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

replace_llm_placeholders() {
    local values_file="$1"
    local backup_file="${values_file}.llm.backup"

    if [[ -f "$backup_file" ]]; then
        log_message "info" "Restoring ${values_file} from backup"
        mv "$backup_file" "$values_file"
        log_message "info" "Deleting leftover backup file"
        rm -f "$backup_file"
    fi

    log_message "info" "Replacing placeholders with values"
    if [[ "$OSTYPE" == "darwin"* ]]; then
           # macOS/BSD sed syntax (requires backup extension)
        sed -i '.llm.backup' "s|%%LLM_QUALITY_MODEL_NAME%%|${LLM_QUALITY_MODEL_NAME}|g" "${values_file}"
        sed -i '.llm.backup' "s|%%LLM_BALANCED_MODEL_NAME%%|${LLM_BALANCED_MODEL_NAME}|g" "${values_file}"
        sed -i '.llm.backup' "s|%%LLM_EFFICIENCY_MODEL_NAME%%|${LLM_EFFICIENCY_MODEL_NAME}|g" "${values_file}"
        sed -i '.llm.backup' "s|%%LLM_EMBEDDING_MODEL_NAME%%|${LLM_EMBEDDING_MODEL_NAME}|g" "${values_file}"
        sed -i '.llm.backup' "s|%%LLM_AWS_REGION_NAME%%|${LLM_AWS_REGION_NAME}|g" "${values_file}"
    else
           # GNU sed (Linux syntax; doesn't require extension)
        sed -i.llm.backup "s|%%LLM_QUALITY_MODEL_NAME%%|${LLM_QUALITY_MODEL_NAME}|g" "${values_file}"
        sed -i.llm.backup "s|%%LLM_BALANCED_MODEL_NAME%%|${LLM_BALANCED_MODEL_NAME}|g" "${values_file}"
        sed -i.llm.backup "s|%%LLM_EFFICIENCY_MODEL_NAME%%|${LLM_EFFICIENCY_MODEL_NAME}|g" "${values_file}"
        sed -i.llm.backup "s|%%LLM_EMBEDDING_MODEL_NAME%%|${LLM_EMBEDDING_MODEL_NAME}|g" "${values_file}"
        sed -i.llm.backup "s|%%LLM_AWS_REGION_NAME%%|${LLM_AWS_REGION_NAME}|g" "${values_file}"
    fi
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

replace_image_version_placeholders() {
    local values_file="$1"
    local image_version="$2"
    local backup_file="${values_file}.img.version.backup"

    if [[ -f "$backup_file" ]]; then
        log_message "info" "Restoring ${values_file} from backup"
        mv "$backup_file" "$values_file"
        log_message "info" "Deleting leftover backup file"
        rm -f "$backup_file"
    fi

    log_message "info" "Replacing placeholders with values"
    if [[ "$OSTYPE" == "darwin"* ]]; then
           # macOS/BSD sed syntax (requires backup extension)
        sed -i '.img.version.backup' "s|%%IMAGE_VERSION%%|${image_version}|g" "${values_file}"
    else
           # GNU sed (Linux syntax; doesn't require extension)
        sed -i.img.version.backup "s|%%IMAGE_VERSION%%|${image_version}|g" "${values_file}"
    fi
}

configure_kubectl() {
    log_message "info" "Configuring kubectl with current cluster ..."
    aws eks update-kubeconfig --region ${AWS_REGIONS} --name ${TF_VAR_platform_name}
}

load_configuration() {
  SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
  CONFIG_FILE="$(dirname "$SCRIPT_DIR")/deployment.conf"

  if [ -f "$CONFIG_FILE" ]; then
      log_message "info" "Loading configuration from $CONFIG_FILE"
      set -a
      source "$CONFIG_FILE"
      set +a
  else
      log_message "fail" "Configuration file $CONFIG_FILE not found"
      echo "Please create a configuration file"
      exit 1
  fi

  DEPLOYMENT_ENV_FILE="$(dirname "$SCRIPT_DIR")/deployment_outputs.env"

  if [ -f "$DEPLOYMENT_ENV_FILE" ]; then
      log_message "info" "Loading configuration from $DEPLOYMENT_ENV_FILE"
      set -a
      source "$DEPLOYMENT_ENV_FILE"
      set +a
  else
      log_message "fail" "Configuration file $DEPLOYMENT_ENV_FILE not found"
      echo "Please run terraform.sh first"
      exit 1
  fi
}

print_summary() {
    log_message "info" "Deployment Summary"
    log_message "info" "=================="
    log_message "info" "All deployments completed successfully."
    log_message "info" "Log file: $LOG_FILE"
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

#################
# k8s Functions
#################

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


deploy_redis() {
  local namespace="aice"

  log_message "info" "Starting Redis deployment"

  check_and_create_namespace "$namespace"

  log_message "info" "Deploying Redis Helm Chart ..."

  helm upgrade \
      --install aice-redis redis/. \
      --namespace "$namespace" \
      --values "redis/values.yaml" \
      --set auth.enabled=false \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Redis deployment completed"
    else
        log_message "fail" "Failed to deploy Redis."
        exit 1
    fi

    log_message "success" "Redis configuration completed"
}

deploy_elasticsearch() {
  local namespace="aice"

  log_message "info" "Starting Elasticsearch deployment"

  check_and_create_namespace "$namespace"

  log_message "info" "Deploying Elasticsearch Helm Chart ..."

  helm upgrade \
      --install aice-elasticsearch elasticsearch/. \
      --namespace "$namespace" \
      --values "elasticsearch/values.yaml" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Elasticsearch deployment completed"
    else
        log_message "fail" "Failed to deploy Elasticsearch."
        exit 1
    fi

    log_message "success" "Elasticsearch configuration completed"
}

deploy_neo4j() {
  local namespace="aice"

  log_message "info" "Starting Neo4j deployment"

  check_and_create_namespace "$namespace"

  if ! check_k8s_secret_exists "$namespace" aice-neo4j-secret; then
    local rdm_pwd="$(openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 12)"

    kubectl -n $namespace create secret generic aice-neo4j-secret \
        --from-literal=username="neo4j" \
        --from-literal=password="${rdm_pwd}" \
        --from-literal=auth="neo4j/${rdm_pwd}" > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Secret 'aice-neo4j-secret' created successfully."
    else
        log_message "fail" "Failed to create secret 'aice-neo4j-secret'."
        exit 1
    fi
  fi

  log_message "info" "Deploying Neo4j Helm Chart ..."

  helm upgrade \
      --install aice-neo4j neo4j/. \
      --namespace "$namespace" \
      --values "neo4j/values.yaml" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Neo4j deployment completed"
    else
        log_message "fail" "Failed to deploy Neo4j."
        exit 1
    fi

    log_message "success" "Copying Neo4j plugins ..."
    kubectl cp $SCRIPT_DIR/artifacts/neo4j/plugins/dozerdb-plugin-5.26.3.0.jar aice-neo4j-0:/plugins -c neo4j -n "$namespace"
    kubectl exec aice-neo4j-0 -c neo4j -n "$namespace" -- chown neo4j:neo4j /plugins/dozerdb-plugin-5.26.3.0.jar

    kubectl cp $SCRIPT_DIR/artifacts/neo4j/plugins/apoc-5.26.3-core.jar aice-neo4j-0:/plugins -c neo4j -n "$namespace"
    kubectl exec aice-neo4j-0 -c neo4j -n "$namespace" -- chown neo4j:neo4j /plugins/apoc-5.26.3-core.jar

    kubectl cp $SCRIPT_DIR/artifacts/neo4j/plugins/neo4j-graph-data-science-2.13.4.jar aice-neo4j-0:/plugins -c neo4j -n "$namespace"
    kubectl exec aice-neo4j-0 -c neo4j -n "$namespace" -- chown neo4j:neo4j /plugins/neo4j-graph-data-science-2.13.4.jar

    kubectl rollout restart statefulset aice-neo4j -n "$namespace"


    log_message "success" "Neo4j configuration completed"
}

deploy_code-exploration-api() {
  local namespace="aice"
  local image_repository="$1"
  local image_version="$2"
  local domain_value="$3"
  local values_file="code-exploration-api/values.yaml"
  local jwt_public_key="$4"

  log_message "info" "Starting Code Exploration API deployment"

  check_and_create_namespace "$namespace"

  replace_image_repository_placeholders "${values_file}" "${image_repository}"
  replace_image_version_placeholders "${values_file}" "${image_version}"
  replace_domain_placeholders "${values_file}" "${domain_value}"
  replace_llm_placeholders "${values_file}"

  log_message "info" "Deploying Code Exploration API Helm Chart ..."

  helm upgrade \
      --install aice-code-exploration-api code-exploration-api/. \
      --namespace "$namespace" \
      --values "${values_file}" \
      --set-file jwtPublicKey.keyData="${jwt_public_key}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Code Exploration API deployment completed"
    else
        log_message "fail" "Failed to deploy Code Exploration API."
        exit 1
    fi

    log_message "success" "Code Exploration API configuration completed"
}

deploy_code-analysis-datasource() {
  local namespace="aice"
  local image_repository="$1"
  local image_version="$2"
  local domain_value="$3"
  local values_file="code-analysis-datasource/values.yaml"

  log_message "info" "Starting Code Analysis Datasource deployment"

  check_and_create_namespace "$namespace"

  replace_image_repository_placeholders "${values_file}" "${image_repository}"
  replace_image_version_placeholders "${values_file}" "${image_version}"
  replace_domain_placeholders "${values_file}" "${domain_value}"

  log_message "info" "Deploying Code Analysis Datasource Helm Chart ..."

  helm upgrade \
      --install aice-code-analysis-datasource code-analysis-datasource/. \
      --namespace "$namespace" \
      --values "${values_file}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Code Analysis Datasource deployment completed"
    else
        log_message "fail" "Failed to deploy Code Analysis Datasource."
        exit 1
    fi

    log_message "success" "Code Analysis Datasource configuration completed"
}

deploy_code-exploration-ui() {
  local namespace="aice"
  local image_repository="$1"
  local image_version="$2"
  local domain_value="$3"
  local values_file="code-exploration-ui/values.yaml"

  log_message "info" "Starting Code Exploration UI deployment"

  check_and_create_namespace "$namespace"

  replace_image_repository_placeholders "${values_file}" "${image_repository}"
  replace_image_version_placeholders "${values_file}" "${image_version}"
  replace_domain_placeholders "${values_file}" "${domain_value}"

  log_message "info" "Deploying Code Exploration UI Helm Chart ..."

  helm upgrade \
      --install aice-code-exploration-ui code-exploration-ui/. \
      --namespace "$namespace" \
      --values "${values_file}" \
      --wait \
      --timeout 600s \
      --dependency-update > /dev/null

    # shellcheck disable=SC2181
    if [ $? -eq 0 ]; then
        log_message "success" "Code Exploration UI deployment completed"
    else
        log_message "fail" "Failed to deploy Code Exploration UI."
        exit 1
    fi

    log_message "success" "Code Exploration UI configuration completed"
}

deploy_aws_rds() {
    local namespace="aice"
    local postgres_secret_name="aice-postgresql-secret"

    log_message "info" "Starting AICE PostgreSQL deployment."
    check_and_create_namespace "$namespace"

    if ! check_k8s_secret_exists "$namespace" "$postgres_secret_name"; then
        kubectl -n $namespace create secret generic $postgres_secret_name \
            --from-literal=password="${AWS_RDS_DATABASE_PASSWORD}" \
            --from-literal=user="${AWS_RDS_DATABASE_USER}" \
            --from-literal=host="${AWS_RDS_ADDRESS}" \
            --from-literal=db="${AWS_RDS_DATABASE_NAME}" > /dev/null

        # shellcheck disable=SC2181
        if [ $? -eq 0 ]; then
            log_message "success" "Secret '$postgres_secret_name' created successfully."
        else
            log_message "fail" "Failed to create secret '$postgres_secret_name'."
            exit 1
        fi
    fi
}


main() {
  echo "AI/Run AICE Helm Charts Deployment Script is starting..."
  echo "================================"

  exec > >(tee -a "$LOG_FILE") 2>&1

  load_configuration
  verify_configs

  configure_kubectl

  # Repos
  helm repo add bitnami https://charts.bitnami.com/bitnami
  helm repo update

  deploy_redis
  deploy_elasticsearch
  deploy_neo4j
  deploy_aws_rds

  deploy_code-exploration-api "${IMAGE_REPOSITORY}" "${CODE_EXPLORATION_API_VERSION}" "${DOMAIN_NAME}" "${JWT_PUBLIC_KEY}"
  deploy_code-analysis-datasource "${IMAGE_REPOSITORY}" "${CODE_ANALYSIS_DATASOURCE_VERSION}" "${DOMAIN_NAME}"
  deploy_code-exploration-ui "${IMAGE_REPOSITORY}" "${CODE_EXPLORATION_UI_VERSION}" "${DOMAIN_NAME}"
}

main "$@"