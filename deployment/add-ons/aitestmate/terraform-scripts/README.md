# AI/Run TestMate AWS Terraform Module

## Requirements

- Terraform version: `>= 1.5.7`

## Notes

Ensure you configure a proper backend for state management if required for your environment.

## Customizing Default Variables

Default variables can be customized by assigning values in a `terraform.tfvars` file.
Also variables could be set via `TF_VAR_<variable>=<value>` environment variable.

## Usage

1. Initialize Terraform:
   ```bash
   terraform init --var-file terraform.tfvars
   ```
2. Validate and review the plan:
   ```bash
   terraform plan --var-file terraform.tfvars
   ```
3. Apply the configuration:
   ```bash
   terraform apply --var-file terraform.tfvars
   ```
