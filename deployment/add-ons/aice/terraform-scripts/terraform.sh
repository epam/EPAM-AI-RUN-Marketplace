#!/bin/bash

##############################################################################
# AI/Run AICE AWS Deployment Script
#
# This script automates the deployment of the AWS RDS Postgresql
##############################################################################

set -euo pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CONFIG_FILE="$(dirname "$SCRIPT_DIR")/deployment.conf"
LOG_FILE="$SCRIPT_DIR/logs/aice_aws_deployment_$(date +%Y-%m-%d-%H%M%S).log"
TERRAFORM_DIR="$SCRIPT_DIR"

if [ ! -d "$SCRIPT_DIR/logs" ]; then
    mkdir "$SCRIPT_DIR/logs"
fi

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

validate_configuration() {
    local required_vars=(
        "AWS_REGIONS"
        "BACKEND_BUCKET_NAME"
        "BACKEND_LOCK_DYNAMODB_TABLE"
        "AWS_DEPLOYER_ROLE_ARN"
    )

    local config_error=0

    for var in "${required_vars[@]}"; do
        if [ -z "${!var:-}" ]; then
            log_message "fail" "Required variable '$var' is not set or is empty in the configuration file."
            config_error=1
        fi
    done

    return $config_error
}

clean_terraform() {
    # Find and delete Terraform-generated files and folders
    find . -type d -name ".terraform" -exec rm -rf {} +
    find . -type f -name ".terraform.lock.hcl" -delete
    find . -type f -name "terraform.tfstate" -delete
    find . -type f -name "terraform.tfstate.backup" -delete
    find . -type f -name "tfplan" -delete

    echo "Terraform-generated files and folders have been deleted."
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
        echo "Please create a configuration file or specify an alternate file with --config-file"
        exit 1
    fi
}

save_deployment_outputs() {
    local output_file="$(dirname "$SCRIPT_DIR")/deployment_outputs.env"

    log_message "info" "Saving deployment outputs to $output_file"

    cat > "$output_file" << EOL
# AICE Deployment Outputs
# Generated: $(date)
# DO NOT COMMIT THIS FILE TO VERSION CONTROL

# RDS Outputs
AWS_RDS_ADDRESS=${AWS_RDS_ADDRESS:-}
AWS_RDS_DATABASE_NAME=${AWS_RDS_DATABASE_NAME:-}
AWS_RDS_DATABASE_USER=${AWS_RDS_DATABASE_USER:-}
AWS_RDS_DATABASE_PASSWORD=${AWS_RDS_DATABASE_PASSWORD:-}
EOL

    chmod 600 "$output_file"

    log_message "success" "Deployment outputs saved to $output_file"
    log_message "warn" "This file contains sensitive information. Keep it secure and do not commit to version control."
}

print_summary() {
    log_message "info" "All deployments completed successfully."
    log_message "info" "Deployment outputs have been saved to deployment_outputs.env"
    log_message "info" "Log file: $LOG_FILE"
}

###################
# Deployment Steps
###################

deploy_rds() {
    log_message "info" "Deploying RDS Postgres..."

    cd "$TERRAFORM_DIR/aice-aws-rds" || exit
    export S3_RDS_BUCKET_KEY_PATH="${AWS_REGIONS}/codemie/aice_rds_terraform.tfstate"
    export S3_CORE_BUCKET_KEY_PATH="${AWS_REGIONS}/codemie/platform_terraform.tfstate"

    terraform init \
        -backend-config="bucket=${BACKEND_BUCKET_NAME}" \
        -backend-config="key=${S3_RDS_BUCKET_KEY_PATH}" \
        -backend-config="region=${AWS_REGIONS}" \
        -backend-config="acl=bucket-owner-full-control" \
        -backend-config="dynamodb_table=${BACKEND_LOCK_DYNAMODB_TABLE}" \
        -backend-config="encrypt=true"
    terraform plan \
        -var="role_arn=${AWS_DEPLOYER_ROLE_ARN}" \
        -var="vpc_state_bucket=${BACKEND_BUCKET_NAME}" \
        -var="vpc_state_key=${S3_CORE_BUCKET_KEY_PATH}" \
        -var="region=${AWS_REGIONS}" \
        -var="backend_lock_dynamodb_table=${BACKEND_LOCK_DYNAMODB_TABLE}" \
        -out=tfplan
    terraform apply \
        -auto-approve tfplan

    AWS_RDS_ADDRESS=$(terraform output -raw address)
    AWS_RDS_DATABASE_NAME=$(terraform output -raw database_name)
    AWS_RDS_DATABASE_USER=$(terraform output -raw database_user)
    AWS_RDS_DATABASE_PASSWORD=$(terraform output -raw database_password)

}

main() {
    echo "AI/Run AICE AWS Deployment Script is starting..."
    echo "================================"

    load_configuration "$CONFIG_FILE"
    validate_configuration

    clean_terraform

#    RDS
    deploy_rds

    save_deployment_outputs
    print_summary
    }

main "$@"