#!/bin/bash

##############################################################################
# AI/Run CodeMie AWS Deployment Script
#
# This script automates the deployment of the infrastructure for AI/Run CodeMie platform on AWS
# including core infrastructure.
##############################################################################

set -euo pipefail

# Enable AWS RDS
AWS_RDS_ENABLE=0 # 0 means true for wider compatibility

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DEFAULT_CONFIG_FILE="$SCRIPT_DIR/deployment.conf"
LOG_FILE="$SCRIPT_DIR/logs/codemie_aws_deployment_$(date +%Y-%m-%d-%H%M%S).log"
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

display_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  --access-key ACCESS_KEY    AWS Access Key"
    echo "  --secret-key SECRET_KEY    AWS Secret Access Key"
    echo "  --region REGION            AWS Region"
    echo "  --rds-enable               Create AWS RDS"
    echo "  -f, --config-file FILE     Load configuration from file (default: $DEFAULT_CONFIG_FILE)"
    echo "  -h, --help                 Display this help message"
    exit 1
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --access-key)
                AWS_ACCESS_KEY_ID="$2"
                shift 2
                ;;
            --secret-key)
                AWS_SECRET_ACCESS_KEY="$2"
                shift 2
                ;;
            --region)
                AWS_DEFAULT_REGION="$2"
                shift 2
                ;;
            --rds-disable)
                AWS_RDS_ENABLE=1
                shift
                ;;
            -f|--config-file)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -h|--help)
                display_usage
                ;;
            *)
                echo "Unknown option: $1"
                display_usage
                ;;
        esac
    done

    if [ -z "${CONFIG_FILE:-}" ]; then
        CONFIG_FILE="$DEFAULT_CONFIG_FILE"
    fi
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

validate_configuration() {
    local required_vars=(
        "TF_VAR_region"
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

validate_aws_credentials() {
    local required_vars=(
        "AWS_ACCESS_KEY_ID"
        "AWS_SECRET_ACCESS_KEY"
        "AWS_DEFAULT_REGION"
    )
    local missing_vars=()
    local param_count=0

    # Check parameter existence
    for var in "${required_vars[@]}"; do
        if [[ -n "${!var:-}" ]]; then
            ((param_count++))
        else
            missing_vars+=("$var")
        fi
    done

    # Handle partial parameters (1-2 provided)
    if [[ $param_count -gt 0 && $param_count -lt 3 ]]; then
        log_message "warn" "Missing required parameters:"
        for var in "${missing_vars[@]}"; do
            log_message "warn" "  - $var"
        done
        return 1
    elif [[ $param_count -eq 3 ]]; then
        aws configure set aws_region "$AWS_DEFAULT_REGION" --profile default
        aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" --profile default
        aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" --profile default
        log_message "success" "Using credentials and region from arguments."
    else
        log_message "info" "No credentials/region passed. Relying on AWS CLI default configuration."
    fi
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

#######################
# Prerequisite Checks
#######################

check_prerequisites() {
    log_message "info" "Checking for required prerequisites..."

    if ! command -v aws &> /dev/null; then
        log_message "fail" "AWS CLI is not installed."
        log_message "info" "Please install AWS CLI first"
        exit 1
    fi

    log_message "success" "All prerequisites are available."
}

verify_aws_login() {
    log_message "info" ""
    log_message "info" "Checking AWS login status..."

    # Check AWS credentials
    if ! aws sts get-caller-identity &> /dev/null; then
        log_message "fail" "You are not logged into AWS."
        log_message "info" "Please configure AWS credentials using: aws configure"
        exit 1
    fi

    # Get current account details
    local current_account
    current_account=$(aws sts get-caller-identity --query "Account" --output text)
    current_user=$(aws sts get-caller-identity --query "Arn" --output text)

    log_message "info" "Current AWS account:"
    log_message "info" "Account ID: $current_account"
    log_message "info" "User ARN: $current_user"
    log_message "info" ""
}

###################
# Deployment Steps
###################
deploy_iam_role() {
    log_message "info" "IAM Deployer role creation..."

    cd "$TERRAFORM_DIR/codemie-aws-iam" || exit

    terraform init
    terraform plan -out=tfplan
    terraform apply -auto-approve tfplan

    AWS_DEPLOYER_ROLE_ARN=$(terraform output -raw deployer_iam_role_arn)
    AWS_DEPLOYER_ROLE_NAME=$(terraform output -raw deployer_iam_role_name)

    if [ -z "$AWS_DEPLOYER_ROLE_ARN" ] || [ -z "$AWS_DEPLOYER_ROLE_NAME" ]; then
        log_message "fail" "Failed to retrieve terraform deployer role details"
        exit 1
    fi

    log_message "info" "Following role will be used for env creation:"
    log_message "info" "IAM Deployer role Name: $AWS_DEPLOYER_ROLE_NAME"
    log_message "info" "IAM Deployer role ARN: $AWS_DEPLOYER_ROLE_ARN"
    log_message "success" "IAM Deployer role creation deployment completed."
}

deploy_terraform_backend_storage() {
    log_message "info" "Deploying terraform backend storage..."

    cd "$TERRAFORM_DIR/codemie-aws-remote-backend" || exit

    terraform init
    terraform plan \
      -var="role_arn=${AWS_DEPLOYER_ROLE_ARN}" \
      -out=tfplan
    terraform apply -auto-approve tfplan

    BACKEND_BUCKET_NAME=$(terraform output -raw terraform_states_s3_bucket_name)
    BACKEND_LOCK_DYNAMODB_TABLE=$(terraform output -raw terraform_lock_table_dynamodb_id)

    if [ -z "$BACKEND_BUCKET_NAME" ] || [ -z "$BACKEND_LOCK_DYNAMODB_TABLE" ]; then
        log_message "fail" "Failed to retrieve terraform storage account details"
        exit 1
    fi

    log_message "info" "Terraform state will be stored in:"
    log_message "info" "S3 Bucket Name: $BACKEND_BUCKET_NAME"
    log_message "info" "Lock DynamoDB Table: $BACKEND_LOCK_DYNAMODB_TABLE"
    log_message "success" "Terraform backend storage deployment completed."

    export BACKEND_BUCKET_NAME
    export BACKEND_LOCK_DYNAMODB_TABLE
}

deploy_core_infrastructure() {
    log_message "info" "Deploying core infrastructure for the CodeMie platform..."

    cd "$TERRAFORM_DIR/codemie-aws-platform" || exit
    export S3_CORE_BUCKET_KEY_PATH="${TF_VAR_region}/codemie/platform_terraform.tfstate"

    log_message "info" "Initializing Terraform with backend configuration..."
    terraform init \
        -backend-config="bucket=${BACKEND_BUCKET_NAME}" \
        -backend-config="key=${S3_CORE_BUCKET_KEY_PATH}" \
        -backend-config="region=${TF_VAR_region}" \
        -backend-config="acl=bucket-owner-full-control" \
        -backend-config="dynamodb_table=${BACKEND_LOCK_DYNAMODB_TABLE}" \
        -backend-config="encrypt=true"

    if [ -z "${TF_VAR_eks_admin_role_arn:-}" ]; then
        terraform plan \
          -var="role_arn=${AWS_DEPLOYER_ROLE_ARN}" \
          -var="eks_admin_role_arn=${current_user}" \
          -out=tfplan
    else
        terraform plan \
          -var="role_arn=${AWS_DEPLOYER_ROLE_ARN}" \
          -var="eks_admin_role_arn=${TF_VAR_eks_admin_role_arn}" \
          -out=tfplan
    fi

    terraform apply -auto-approve tfplan

    local outputs=(
        "region"
        "codemie_aws_role_arn"
        "codemie_kms_key_id"
        "codemie_s3_bucket_name"
    )

    for output in "${outputs[@]}"; do
        value=$(terraform output -raw "$output" 2>/dev/null || echo "")
        eval "output_${output}=\"$value\""

        if [ -z "$value" ]; then
            log_message "warn" "Failed to retrieve output: $output"
        fi
    done

    # Export using the dynamically named variables
    export AWS_DEFAULT_REGION="$output_region"
    export EKS_AWS_ROLE_ARN="$output_codemie_aws_role_arn"
    export AWS_KMS_KEY_ID="$output_codemie_kms_key_id"
    export AWS_S3_BUCKET_NAME="$output_codemie_s3_bucket_name"

    log_message "info" ""
    log_message "info" "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
    log_message "info" "EKS_AWS_ROLE_ARN: $EKS_AWS_ROLE_ARN"
    log_message "info" "AWS_KMS_KEY_ID: $AWS_KMS_KEY_ID"
    log_message "info" "AWS_S3_BUCKET_NAME: $AWS_S3_BUCKET_NAME"
    log_message "success" "Core infrastructure deployment completed."
}

deploy_rds() {
    log_message "info" "Deploying RDS Postgres..."

    cd "$TERRAFORM_DIR/codemie-aws-rds" || exit
    export S3_RDS_BUCKET_KEY_PATH="${TF_VAR_region}/codemie/rds_terraform.tfstate"

    terraform init \
        -backend-config="bucket=${BACKEND_BUCKET_NAME}" \
        -backend-config="key=${S3_RDS_BUCKET_KEY_PATH}" \
        -backend-config="region=${TF_VAR_region}" \
        -backend-config="acl=bucket-owner-full-control" \
        -backend-config="dynamodb_table=${BACKEND_LOCK_DYNAMODB_TABLE}" \
        -backend-config="encrypt=true"
    terraform plan \
        -var="role_arn=${AWS_DEPLOYER_ROLE_ARN}" \
        -var="vpc_state_bucket=${BACKEND_BUCKET_NAME}" \
        -var="vpc_state_key=${S3_CORE_BUCKET_KEY_PATH}" \
        -var="region=${TF_VAR_region}" \
        -var="backend_lock_dynamodb_table=${BACKEND_LOCK_DYNAMODB_TABLE}" \
        -out=tfplan
    terraform apply \
        -auto-approve tfplan

    AWS_RDS_ADDRESS=$(terraform output -raw address)
    AWS_RDS_DATABASE_NAME=$(terraform output -raw database_name)
    AWS_RDS_DATABASE_USER=$(terraform output -raw database_user)
    AWS_RDS_DATABASE_PASSWORD=$(terraform output -raw database_password)

}

save_deployment_outputs() {
    local output_file="$SCRIPT_DIR/deployment_outputs.env"

    log_message "info" "Saving deployment outputs to $output_file"

    cat > "$output_file" << EOL
# CodeMie Platform Deployment Outputs
# Generated: $(date)
# DO NOT COMMIT THIS FILE TO VERSION CONTROL

# Platform Outputs
AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}
EKS_AWS_ROLE_ARN=${EKS_AWS_ROLE_ARN}
AWS_KMS_KEY_ID=${AWS_KMS_KEY_ID}
AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}
AWS_DEPLOYER_ROLE_ARN=${AWS_DEPLOYER_ROLE_ARN}

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
    log_message "info" "Deployment Summary"
    log_message "info" "=================="
    log_message "info" "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
    log_message "info" "EKS_AWS_ROLE_ARN: $EKS_AWS_ROLE_ARN"
    log_message "info" "AWS_KMS_KEY_ID: $AWS_KMS_KEY_ID"
    log_message "info" "AWS_S3_BUCKET_NAME: $AWS_S3_BUCKET_NAME"
    log_message "info" "=================="
    log_message "info" "All deployments completed successfully."
    log_message "info" "Deployment outputs have been saved to deployment_outputs.env"
    log_message "info" "Log file: $LOG_FILE"
}

################
# Main Function
################

main() {
    echo "AI/Run CodeMie AWS Deployment Script"
    echo "================================"

    export TF_CLI_ARGS="-no-color"
    exec > >(tee -a "$LOG_FILE") 2>&1

    parse_arguments "$@"
    load_configuration "$CONFIG_FILE"

    if ! validate_configuration; then
        log_message "fail" "One or more required variables are not properly set in $CONFIG_FILE"
        echo "Please update your configuration file and try again."
        exit 1
    fi

    if ! validate_aws_credentials; then
        log_message "fail" "You must provide all three: --access-key, --secret-key, and --region or none of them."
        display_usage
    fi

    check_prerequisites
    verify_aws_login

    deploy_iam_role
    sleep 20
    deploy_terraform_backend_storage
    sleep 20
    deploy_core_infrastructure
    sleep 20
    if [ "$AWS_RDS_ENABLE" -eq 0 ]; then # DB instance class and version - to check
        deploy_rds
    fi

    save_deployment_outputs
    print_summary
}

main "$@"