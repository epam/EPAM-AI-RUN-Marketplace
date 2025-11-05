#!/bin/bash

##############################################################################
# AI/Run AICE AWS Deployment Script
#
# This script automates the deployment of the AICE Extension
##############################################################################

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$SCRIPT_DIR/deployment.conf"

###################
# Helper Functions
###################
log_message() {
    local status="$1"
    local message="$2"
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

load_configuration() {
    local config_file="$1"

    if [ -f "$config_file" ]; then
        log_message "info" "Loading configuration from $config_file"
        set -a
        source "$config_file"
        set +a
    else
        log_message "fail" "Configuration file $config_file not found"
        echo "Please create a configuration file"
        exit 1
    fi
}

validate_configuration() {
    local required_vars=(
        "AWS_REGIONS"
        "BACKEND_BUCKET_NAME"
        "BACKEND_LOCK_DYNAMODB_TABLE"
        "IMAGE_REPOSITORY"
        "CODE_EXPLORATION_API_VERSION"
        "CODE_EXPLORATION_UI_VERSION"
        "CODE_ANALYSIS_DATASOURCE_VERSION"
        "DOMAIN_NAME"
        "LLM_AWS_REGION_NAME"
        "LLM_QUALITY_MODEL_NAME"
        "LLM_BALANCED_MODEL_NAME"
        "LLM_EFFICIENCY_MODEL_NAME"
        "LLM_EMBEDDING_MODEL_NAME"
        "JWT_PUBLIC_KEY"
    )

    local config_error=0

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log_message "fail" "Required variable '$var' is not set or is empty in the configuration file."
            config_error=1
        fi
    done

    log_message "info" "Validation of configuration file has been finished."

    return $config_error
}

main() {
    echo "AI/Run AICE Deployment Script"
    echo "================================"

    load_configuration "$CONFIG_FILE"
    validate_configuration

    # Terraform
    chmod +x "$SCRIPT_DIR/terraform-scripts/terraform.sh"
    "$SCRIPT_DIR/terraform-scripts/terraform.sh"

    # Helm Charts
    chmod +x "$SCRIPT_DIR/helm-scripts/install.sh"
    "$SCRIPT_DIR/helm-scripts/install.sh"

    }

main "$@"