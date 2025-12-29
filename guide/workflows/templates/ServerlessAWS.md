# Table of Contents

- [Solution Overview](#solution-overview)
- [General Requirements](#general-requirements)
  - [Tools and Runtime Environment](#tools-and-runtime-environment)
  - [AWS Account and Credentials](#aws-account-and-credentials)
  - [Project Preparation](#project-preparation)
  - [Workflow-Specific Requirements](#workflow-specific-requirements)
  - [Platform & Permissions](#platform--permissions)
  - [Setting codemie-plugins and enabling access to your local files](#setting-codemie-plugins-and-enabling-access-to-your-local-files)
- [Step-by-Step Stages Description](#step-by-step-stages-description)
  - [Project Discovery](#project-discovery)
  - [Lambda Writer](#lambda-writer)
  - [API Gateway](#api-gateway)
  - [Lambda Build](#lambda-build)
  - [Terraform Lambda Config](#terraform-lambda-config)
  - [Module DynamoDB](#module-dynamodb)
  - [Terraform Deploy](#terraform-deploy)
- [All-in-One Workflow Description](#all-in-one-workflow-description)

---

# Solution Overview

This workflow solution provides a modular and extensible automation framework for migrating monolithic applications to 
AWS Lambda-based serverless architecture. Each stage of process is represented by an explicit workflow template, 
supporting both step-by-step execution and full pipeline automation.

**Key stages and templates:**
- **Project Discovery**: Analyze your application codebase to identify components suitable for migration to AWS Lambda. 
Generates migration artifacts for subsequent transformation steps.
- **Lambda Writer**: Converts defined, migratable components into AWS Lambda function code and produces supplementary 
metadata for build and deployment.
- **API Gateway Template**: Automatically generates Terraform configuration for exposing Lambda handlers as HTTP 
endpoints via AWS API Gateway.
- **Lambda Build**: Executes language- and platform-aware build scripts for Lambda packaging and artifact preparation.
- **Terraform Lambda Config**: Generates necessary Terraform configuration for deploying Lambda functions and 
related resources.
- **Module DynamoDB**: Validates and adjusts DynamoDB resource definitions for Lambda configurations where DynamoDB 
is required.
- **Terraform Deploy**: Semi-automates Terraform deployment cycle with commands for initialization, planning, 
application, and error fixing.
- **All-in-One Workflow**: Orchestrates all above stages in a single, unified pipeline, supporting context sharing,
checkpointing, and holistic migration for target application.

All workflow steps are executed in an isolated workspace (by default, under `airun` directory) and do not modify the
source repository directly. Templates employ a mix of agent-driven and tool-based workflow states, adhering to 
recommended best practices for cloud migration and automation.

Workflows in this solution are fully composable: teams can select and run individual stages when a phased approach 
is needed, or trigger integrated pipeline for complete automation. This flexibility supports both incremental 
migration and one-shot transformation scenarios, with robust context management and error recovery.

See individual stage descriptions and usage scenarios below for technical details and execution guidance.

# General Requirements

Before running any stage of monolith-to-AWS Lambda migration workflow, make sure your environment meets 
following prerequisites:

## Tools and Runtime Environment

- **Bash shell** is required for all workflow automation steps.
- **Terraform** (version 1.0 or higher) must be installed and available in your `PATH`.
- **Python** (if your project contains Python components) and other language-specific build tools should be available 
according to your application requirements.
- **AWS CLI** should be installed and properly configured for access to target AWS account (i.e., valid credentials 
and region set).
- Following custom scripts or utilities must be present and accessible from your `PATH`:
  - [nhrun](../resources/nhrun)
  - [nhcheck](../resources/nhcheck)
- **jq** (command-line JSON processor) is recommended for advanced operations during workflow execution.

## AWS Account and Credentials

- An active AWS account with necessary permissions for Lambda, API Gateway, DynamoDB, IAM, S3, and CloudWatch resources 
creation and management.
- AWS access credentials (Access Key ID and Secret Access Key) must be configured and available to workflow 
environment (for example, with `aws configure`).

## Project Preparation

- Prepare application source code in a working directory. Source files should not be modified during workflow; 
all workflow-generated code and configuration will be output to `airun` workspace folder.
- Project dependencies and build files should be accessible if workflow will package Python, Java, or other 
Lambda-supported languages.

## Workflow-Specific Requirements

- For steps requiring DynamoDB validation, ensure that any Database table schemas required by your Lambda code are 
specified and available to workflow.
- Whenever manual approval is required (for example, during `terraform apply`), workflow will prompt for your 
confirmation.

## Platform & Permissions

- Ensure that your user account has permissions to create files and directories in current workspace.
- Outbound internet connectivity is needed for dependency installation during Lambda packaging and for AWS API 
calls.
- Terraform state files and other workflow artifacts will be created in `airun` directory; make sure you have 
sufficient workspace storage.

## Setting codemie-plugins and enabling access to your local files
1. Ensure Python 3.12 or higher installed
2. Ensure Node.js 22 or higher installed
3. Install uvx with command
```bash
  pip install uv
```
4. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```
5. Create folder in root folder of your project: ```airun``` 
6. Add ```00bootstrap.json``` files with next values in ```airun```
```
 {
  "project_base": "absolute_path_to_your_project",  
 }
```
7. Create ```.codemie``` folder at ```<user_home_directory>``` folder 
8. Create ```config.json``` file at ```<user_home_directory>\.codemie``` folder
9. Define default MCP servers and connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
```
 {
  "PLUGIN_KEY": "<Any value>",
  "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
  "mcpServers": {
    "filesystem_ext": {
      "command": "uvx",
      "args": [
        "--from",
        "mcp-filesystem-extra",
        "filesystem-extra"
        ]
    },
    "tree_sitter": {
      "command": "uvx",
      "args": [
        "--from",
        "mcp-server-tree-sitter-extra",
        "mcp-server-tree-sitter"
        ]
    }
  }
 } 
   ```
10. Check list of availability MCP server
```bash
  codemie-plugins mcp list
```
11. Create plugin project integration on AI/Run™ with value from config.json files using PLUGIN_KEY, and "Alias" 
property can be "demo-plugin-integration" or any other user defined value.

12. Run MCP servers and codemie-plugins

    For MacOS & Linux
```bash
  cd <absolute_path_to_your_project>
  export PROJECT_BOOTSTRAP=/<absolute_path_to_your_project>/airun
  export ALLOWED_DIRS=/<absolute_path_to_your_project>
  export FILE_PATHS=/<absolute_path_to_your_project>
  export ALLOWED_DIR=/<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem_ext -e filesystem=FILE_PATHS -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
  cd <absolute_path_to_your_project>
  set PROJECT_BOOTSTRAP= <absolute_path_to_your_project>\airun
  set ALLOWED_DIRS=<absolute_path_to_your_project>
  set FILE_PATHS=<absolute_path_to_your_project>
  set ALLOWED_DIR=<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem-extra -e filesystem=FILE_PATHS -e filesystem-extra=ALLOWED_DIR,PROJECT_BOOTSTRAP
```

---

For details on tool installation and credentials configuration, refer to your internal platform documentation or see 
[AWS CLI User Guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html) and 
[Terraform Installation Guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli).

# Step-by-Step Stages Description

This workflow solution is designed as a sequence of modular stages, with each stage implemented as a dedicated template 
and serving a specific purpose in monolith-to-AWS-Lambda migration process. Step-by-step approach gives 
engineering teams fine-grained control and traceability over every key transformation phase. Individual stages can be 
executed in isolation, allowing for precise validation, troubleshooting, and incremental adoption at project scale.

Following composable workflow methodology, each stage is responsible for a distinct task, such as analysis, Lambda 
code generation, build, infrastructure configuration, or deployment. Intermediate artifacts and results produced by one 
stage are used as inputs for subsequent stages, ensuring clear separation of responsibilities and ease of reuse in 
different migration scenarios.

Running only required stages makes it possible to address complex migration cases selectively, helps to identify 
issues early, and provides flexibility for customizations or extensions. This approach fits teams who need 
staged migration, intermediate checks, or integration with manual quality control steps at any point in pipeline.

See following subsections for list and details of each available stage template.

## Project Discovery

This stage starts migration workflow by analyzing your application's codebase to identify components that are 
suitable for migration to AWS Lambda. It produces explicit lists of "migratable" and "non-migratable" units, providing 
a clear foundation for further processing in subsequent stages.

---

### Prerequisites

- Bash shell is required.
- Make sure **jq**, **[nhrun](../resources/nhrun)**, and **[nhcheck](../resources/nhcheck)** are installed and available 
in your `PATH`.  
- Terraform must be installed (needed for downstream steps).
- Application source code must be present and accessible in your current workspace.
- Workflow only writes to isolated `airun` workspace—it does not change your source repository files.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

#### 2. Launch Project Discovery Workflow

Use EPAM AI/Run™ for AWS platform Web Console**

1. Open EPAM AI/Run™ for AWS platform in your browser.
2. Go to **Workflows** section, then open **Templates** tab.
3. Locate workflow template named `[SERVERLESS][0] Project Discovery`. Verify template content:
```yaml
slug: amna-serverless-00-project-discovery
name: "[SERVERLESS][0] Project Discovery"
description: |
  Automatically discovers current project structure and checks which components can be migrated as AWS Lambdas.
   
  This workflow is a part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: aws_lambda_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert Software Developer, experienced in monolith to serverless migrations 
        with strong knowledge of AWS Lambdas, DynamoDB, API gateways and other AWS services.
        
        You have an access to local project and ability to run tools.
        
        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines

  states:
    - id: analysis
      assistant_id: aws_lambda_expert
      task: |
        You are given the task to analyse the project and identify which components can be migrated to AWS lambdas and which can't.

        If component is suitable/feasible for migration to lambda     - use _append_structured_file tool and write information about the file to <project_base>/airun/migratable.json
        If component is NOT suitable/feasible for migration to lambda - use _append_structured_file tool and write information about the file to <project_base>/airun/non_migratable.json

        The output format is:
        {
          "component_name": "Name of a desired lambda. Use Pascal case for the name.",
          "description": "Short description of it's functionality",
          "sources": [ "List of source files, which contains all the code needed by the new lambda." ],
          "additional_information": "Any relevant information about the component."
          "is_migratable": "true / false"
          "reasoning": "A few sentences why you believe this component is suitable or unsuitable for AWS Lambda migration"
          "language": "The most suitable language for the lambda conversion. (e.g. Python)",
          "endpoint_uri": "Endpoint root URI (e.g. /admin)"
        }
      next:
        state_id: end

```

4. Click **Create Workflow** or **Run** on this template.
5. In workflow creation dialog, assign a unique workflow name.
6. Optionally, set custom parameters or update description.
7. Start execution and monitor progress from workflow executions dashboard.
8. Once complete, download and review results from `airun` directory in your workspace (see below for output 
details).

**Tips:**
- If running in a multi-user/team environment, make sure your “Project” in AI/Run™ for AWS matches context of your 
source repository to prevent accidental overwrites.
- You can name and tag different workflow runs to keep track of various discovery attempts.
- For additional help, see [Workflows Overview Guide](../../guide/workflows/README.md) in your platform 
documentation.

#### 3. Review Outputs

After successful workflow execution, two JSON files will appear in `airun` directory:
- `airun/migratable.json` (AWS Lambda candidates)
- `airun/non_migratable.json` (components not eligible for migration)

Each entry in `migratable.json` includes:
- `component_name`
- `description`
- `sources`
- `is_migratable`
- `reasoning`
- `language`
- `endpoint_uri`

Example:
```json
{
  "component_name": "UserRegistrationHandler",
  "description": "Handles new user registration requests",
  "sources": ["src/handlers/register.py"],
  "is_migratable": "true",
  "reasoning": "Stateless handler, no local resource dependencies.",
  "language": "Python",
  "endpoint_uri": "/register"
}
```

#### 4. Proceed to Next Step

- Use generated `migratable.json` as input for next migration stage (“Lambda Writer”).
- Review `non_migratable.json` to identify components that may require refactoring.

---

### Notes and Recommendations

- Only files in `airun` directory will be created or modified.
- Run this discovery stage after any major code refactoring for updated analysis.
- This step’s output defines your actual migration inventory—review carefully before proceeding.

**Project Discovery is required foundation for all further workflow stages.**

## Lambda Writer

Lambda Writer stage transforms your identified migratable components into AWS Lambda functions. It generates 
Lambda-compatible source code and related metadata for each component described in your discovery output. This step 
ensures proper build instructions and language-appropriate packaging sequences for subsequent deployment stages.

---

### Prerequisites

- Completion of Project Discovery stage and a valid `airun/migratable.json` file in your workspace.
- **Bash shell** must be available.
- Utilities **jq**, **[nhrun](../resources/nhrun)**, and **[nhcheck](../resources/nhcheck)** must be installed and 
visible in your `PATH`.
- Source code for all components listed in `migratable.json` must be present.
- Workflow only writes to `airun/lambdas` and auxiliary workspace folders—no source code is overwritten.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Make sure `airun/migratable.json` (from discovery step) is present and up to date.

---

#### Step 2: Launch Lambda Writer Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Open EPAM AI/Run™ for AWS platform.
2. Go to **Workflows** section and open **Templates** tab.
3. Find `[SERVERLESS][1] Lambda Writer`. Verify template content:
```yaml
slug: amna-serverless-01-lambda-writer
name: "[SERVERLESS][1] Lambda Writer"
description: |
  Automatically generates AWS Lambdas for discovered migratable components.
  Requires data from "[SERVERLESS][0] Project Discovery" workflow execution.

  This workflow is a part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: aws_lambda_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert Software Developer, experienced in monolith to serverless migrations 
        with strong knowledge of AWS Lambdas, DynamoDB, API gateways and other AWS services.
        
        You have an access to local project and ability to run tools.
        
        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines

  tools:
    - id: read_bootstrap_tool
      tool: _read_bootstrap_file
      toolset: Plugin
      trace: true

  states:
    - id: migratable
      tool_id: read_bootstrap_tool
      tool_args:
        path: migratable.json
      next:
        state_id: lambda_writer
        iter_key: _

    - id: lambda_writer
      assistant_id: aws_lambda_expert
      task: |
        You are given a component and where it is stored. You must convert it to AWS Lambda written in {{language}}.
        Read the file, do the conversion and output the resulting {{language}} text.

        Input parameters and output must be valid JSONs.

        Create the only file with {{language}} AWS lambda code.
        Your output will be passed to specialized assistant that will use AWS API to create Lambda from the code
        fragment you provided.

        If you successfully created lambda - use _append_structured_file tool and write information about the lambda to <project_base>/airun/lambdas/lambda_info.json
        Using the following output format:
        {
          "lambda_name": "{{component_name}}",
          "component_root_dir": "Generated lambda root directory (e.g. <project_base>/airun/lambdas/{{component_name}})",
          "language": "{{language}}",
          "description": "Short description of it's functionality",
          "endpoint_uri": "{{endpoint_uri}}",
        }

        IMPORTANT:
        You are allowed to create lambda files under the <project_base>/airun/lambdas/{{component_name}},
        and you are not allowed to modify or create any files outside of the directory.
        Do not create build script files, readme files or any other non-required files.
      output_schema: |
        {
          "lambda_name": "{{component_name}}",
          "component_root_dir": "Generated lambda root directory (e.g. <project_base>/airun/lambdas/{{component_name}})",
          "language": "{{language}}",
          "description": "Short description of it's functionality",
          "endpoint_uri": "{{endpoint_uri}}",
        }
      next:
        include_in_llm_history: false
        state_id: build_sequence_enricher

    - id: build_sequence_enricher
      assistant_id: aws_lambda_expert
      task: |
        You are given the task to enrich each element of json array with the field "build_sequence".
        Substitute $variable with actual values taken from the enriching element.
    
        Your steps must be the following:
        1. Read <project_path>/airun/lambdas/lambda_info.json file.
        2. Do for each element:
          - Identify the language field.
          - Enrich the element with the "build_sequence" field according to the language value.
    
        Python build sequence must be exactly the following (with substituted variables):
        "build_sequence": [
          "mkdir package",
          "pip install -r requirements.txt -t package",
          "cd package && zip -r $component_root_dir/$lambda_name.zip .",
          "zip $lambda_name.zip lambda_function.py"
        ]
    
        Java build sequence must be exactly the following:
        "build_sequence": ["mvn package"]
    
        You should observe / modify only the <project_path>/airun/lambdas/lambda_info.json file.
        You cannot read / modify / create / delete any other file or directory.
      next:
        state_id: end

```
4. Click **Create Workflow** or **Run**.
5. Assign a workflow name if prompted and adjust parameters as needed.
6. Launch workflow and monitor progress in web console.
7. Upon completion, download generated Lambda code and `lambda_info.json` from `airun/lambdas` folder.

---

#### Step 3: Review Outputs

After successful execution, you will find within `airun/lambdas/`:
- Separate folders for each generated Lambda function (containing source code, requirements, etc.).
- A metadata file: `lambda_info.json` containing build instructions, artifact locations, endpoint URIs, and additional 
details for each function.

Example excerpt from `lambda_info.json`:
```json
{
  "lambda_name": "UserRegistrationHandler",
  "description": "Handles new user registration requests",
  "language": "Python",
  "build_sequence": [
    "mkdir package",
    "pip install -r requirements.txt -t package",
    "cd package && zip -r ../UserRegistrationHandler.zip .",
    "zip UserRegistrationHandler.zip lambda_function.py"
  ],
  "endpoint_uri": "/register"
}
```

---

#### Step 4: Next Steps

- Use generated `lambda_info.json` as input for subsequent workflow steps, such as API Gateway configuration, 
Lambda build, and deployment stages.

---

### Additional Notes

- All Lambda artifacts and metadata remain in `airun/lambdas` — your source code is untouched.
- If you modify `airun/migratable.json`, rerun this step to regenerate Lambda assets.
- Validate generated Lambda code and packaging instructions before moving to next workflow stage.

## API Gateway

API Gateway step automates generation of Terraform configuration for exposing AWS Lambda function endpoints 
using AWS API Gateway. Based on Lambda metadata produced in previous steps, this workflow ensures proper RESTful 
endpoint setup with accurate routing and integration, readying your new serverless back-end for client access and 
further infrastructure deployment.

---

### Prerequisites

- Completion of Lambda Writer stage and presence of a valid `airun/lambdas/lambda_info.json` file.
- **Bash shell** must be installed and available.
- Utilities **jq**, **[nhrun](../resources/nhrun)**, and **[nhcheck](../resources/nhcheck)** must be included in 
your `PATH`.
- **Terraform** must be installed.
- Workflow will only update or create configuration in `airun/terraform` directory, preserving your project
source code.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Verify that outputs from earlier Lambda Writer step, especially `airun/lambdas/lambda_info.json`  are present.

---

#### Step 2: Launch API Gateway Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Access EPAM AI/Run™ for AWS platform in your browser.
2. Go to **Workflows** area, then “Templates”.
3. Locate and select `[SERVERLESS][2] API Gateway Generation`. Verify template content:
```yaml
slug: amna-serverless-02-api-gateway
name: "[SERVERLESS][2] API Gateway Generation"
description: |
  Automatically generates Terraform configuration for AWS API Gateway for generated lambdas.
  Requires data from "[SERVERLESS][1] Lambda Writer" workflow execution.

  This workflow is a part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: aws_terraform_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert DevOps engineer experienced in configuring AWS resources, with the strong knowledge of Terraform.
        You have an access to local project and ability to run tools.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is observe.*
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines
        - name: AWS

  tools:
    - id: read_bootstrap_tool
      tool: _read_bootstrap_file
      toolset: Plugin
      trace: true

  states:
    - id: read_lambdas_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/lambda_info.json
      next:
        state_id: api_gateway_config_generator
        iter_key: _

    - id: api_gateway_config_generator
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to update Terraform configuration files using tools with an api-gateway configuration for the provided lambda.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        Follow these steps to accomplish the task:
        1. Read existing terraform configuration stored at <project_base>/airun/terraform.
        2. Read required to be added lambda.
        3. Identify available aws regions and availability zones, use only one of each.
        4. Update Terraform configuration for api-gateway, ensuring all lambda endpoints are added.
        5. Read all of the terraform files and verify your solution:
          - Ensure all resources used in api-gateway are present in Terraform configuration.
          - Check there are no resource duplicates.
          - Ensure no deprecated arguments used.

        IMPORTANT:
        Do not include anything besides api-gateway configuration, other parts will be added by different agent.
        Do not create any non-configuration files (Do not include README).
        Keep file structure clean. Use one file for one resource type.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is to observe.*
        You are not allowed to create / modify / delete any file outside of the <project_base>/airun/terraform directory.
      next:
        state_id: end
```
4. Click **Create Workflow** or **Run**.
5. Assign a descriptive workflow name.
6. (Optionally) Edit any parameters as appropriate.
7. Launch workflow and track execution on web console.
8. Once complete, retrieve Terraform configuration from `airun/terraform` directory.

---

#### Step 3: Review Outputs

Upon successful workflow completion, a Terraform file will be created or updated:

- `airun/terraform/api_gateway.tf` — contains Terraform resource definitions for each Lambda function’s HTTP endpoint 
according to your Lambda metadata.

This file is structured to avoid resource duplication and adheres to AWS and provider best practices, ensuring clean 
deployment in later infrastructure steps.

---

#### Step 4: Next Steps

- Fenerated API Gateway configuration will be used during deployment and provisioning stages of your workflow 
- pipeline.
- Proceed to next recommended step, such as Lambda build and packaging.

---

### Additional Notes

- Edits are strictly limited to `airun/terraform` directory; your source repo remains untouched.
- You may rerun this stage any time Lambda endpoints or routing requirements change.
- Always validate and review generated Terraform before applying infrastructure changes in production environments.

## Lambda Build

Lambda Build step is responsible for packaging generated Lambda functions according to their programming 
language and specified build instructions. It executes language-aware build commands, prepares deployment-ready Lambda 
artifacts (archives), and produces build information for subsequent deployment and configuration steps.

---

### Prerequisites

- Successful completion of Lambda Writer and API Gateway steps.
- Presence of an up-to-date `airun/lambdas/lambda_info.json` file with relevant build instructions.
- **Bash shell** must be available in your execution environment.
- Utilities **jq**, **[nhrun](../resources/nhrun)**, and **[nhcheck](../resources/nhcheck)** must be installed and 
present in your `PATH`.
- All required project dependencies for Lambda functions should be available locally or defined in conventional 
files (such as `requirements.txt` for Python or `pom.xml` for Java).
- Workflow will create artifacts only under `airun/lambdas/archives` and will not modify your project source code.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Ensure `airun/lambdas/lambda_info.json` file is available and correctly generated from Lambda Writer stage.

---

#### Step 2: Launch Lambda Build Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Open EPAM AI/Run™ for AWS platform.
2. In **Workflows** section, switch to **Templates** tab.
3. Locate and select `[SERVERLESS][3] Lambda Builder`. Verify template content:
```yaml
slug: amna-serverless-03-lambda-builder
name: "[SERVERLESS][3] Lambda Builder"
description: |
  Automatically builds generated Lambdas.
  Requires data from "[SERVERLESS][1] Lambda Writer" workflow execution.

  This workflow is a part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: command_runner
      exclude_extra_context_tools: true
      system_prompt: |
        You are an assistant designed to execute command line tools.
      tools:
        - name: _append_structured_file
        - name: _move_file
        - name: _list_directory
        - name: _directory_tree
        - name: _list_allowed_directories
        - name: _run_command
        - name: _show_security_rules

  tools:
    - id: read_bootstrap_tool
      tool: _read_bootstrap_file
      toolset: Plugin
      trace: true

  states:
    - id: read_lambdas_enriched_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/lambda_info.json
      next:
        state_id: lambda_builder
        iter_key: _

    - id: lambda_builder
      assistant_id: command_runner
      task: |
        1. Build lambda using {{build_sequence}}, from {{component_root_dir}}. Use _run_command tool to accomplish this task.
        2. Create <project_base>/airun/lambdas/archives directory.
        3. Move lambda archive to the airun/lambdas/archives directory.
        4. Clean up.

        Use _append_structured_file tool and write information about the lambda to airun/lambdas/build_info.json
        Using the following output format:
        {
          "lambda_name": "{{component_name}}",
          "lambda_archive_path": "Path to the archive, containing built lambda.",
          "description": "Short description of it's functionality",
          "endpoint_uri": "{{endpoint_uri}}",
          "success": "Displays if archive with lambda was created successfully, true | false."
        }
      next:
        state_id: end
```
4. Click **Create Workflow** or **Run**.
5. Name your workflow for easy reference if prompted.
6. Optionally set or review parameters.
7. Start workflow and monitor execution progress.
8. Upon completion, navigate to `airun/lambdas/archives` and `airun/lambdas/build_info.json` to review your build 
artifacts and metadata.

---

#### Step 3: Review Outputs

After execution, you will find:

- Lambda deployment artifacts (e.g., zipped package files for each Lambda) in `airun/lambdas/archives/`.
- Updated `airun/lambdas/build_info.json` file with build results, archive paths, endpoint URIs, and status for each 
Lambda function.

Sample `build_info.json` entry:
```json
{
  "lambda_name": "UserRegistrationHandler",
  "lambda_archive_path": "airun/lambdas/archives/UserRegistrationHandler.zip",
  "description": "Handles new user registration requests",
  "endpoint_uri": "/register",
  "success": true
}
```

---

#### Step 4: Next Steps

- Pass produced Lambda archives and `build_info.json` file to next workflow stage, such as Terraform Lambda 
configuration and infrastructure deployment.

---

### Additional Notes

- Lambda Build step only generates files in workspace’s `airun/lambdas/archives` and `build_info.json`; your 
source and previously generated Lambda code remain unchanged.
- If you add or update Lambda functions, rerun this step for an up-to-date build.
- Always validate build output before deploying to non-development environments.

## Terraform Lambda Config

Terraform Lambda Config step is responsible for generating and updating Terraform configuration files required to 
deploy AWS Lambda functions and corresponding supporting resources (such as S3 buckets for code storage). This 
workflow ensures each Lambda is properly represented in your infrastructure code, fully prepared for automated 
provisioning.

---

### Prerequisites

- Successful completion of Lambda Build and previous steps.
- A valid `airun/lambdas/build_info.json` file present in your workspace.
- **Bash shell**, **Terraform**, and utilities **jq**, **[nhrun](../resources/nhrun)**, and 
**[nhcheck](../resources/nhcheck)** must be installed and available in your `PATH`.
- All Lambda package archives referenced by `build_info.json` must exist in `airun/lambdas/archives/`.
- This workflow will only modify or generate Terraform files within `airun/terraform` directory. No changes 
are made outside workspace.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Check that `airun/lambdas/build_info.json` file and corresponding Lambda archives are present and up-to-date.

---

#### Step 2: Launch Terraform Lambda Config Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Log in to EPAM AI/Run™ for AWS platform.
2. Navigate to **Workflows** section and open **Templates** tab.
3. Find and select `[SERVERLESS][4] Terraform Lambda Config Generator`. Verify template content:
```yaml
slug: amna-serverless-04-lambda-config-generator
name: "[SERVERLESS][4] Terraform Lambda Config Generator"
description: |
  Automatically generates Terraform configuration for lambda deployment.
  Requires data from "[SERVERLESS][3] Lambda Builder" workflow execution.

  This workflow is a part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: aws_terraform_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert DevOps engineer experienced in configuring AWS resources, with the strong knowledge of Terraform.
        You have an access to local project and ability to run tools.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is observe.*
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines
        - name: AWS

  tools:
    - id: read_bootstrap_tool
      tool: _read_bootstrap_file
      toolset: Plugin
      trace: true

  states:
    - id: read_lambdas_build_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/build_info.json
      next:
        state_id: terraform_lambda_config_writer

    - id: terraform_lambda_config_writer
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to generate configuration for lambda deployment.
        Add only necessary resources. If lambda can be deployed without the resource then it shouldn't be present in configuration.

        Follow these steps to accomplish the task:
        1. Examine all terraform configuration files before trying to change them.
        2. Create *<project_base>/airun/terraform* directory if not present and use it as a working directory. 
        3. Add configuration for the new s3 bucket to store lambdas, skip this step if bucket is already described in terraform configuration.
        4. Generate lambdas configuration. Use *AWS* tool to gather any information about the account.
        5. Verify generated configuration.
          - There should be no mocked resources in the result.
          - Check there are no resource duplicates.
          - Ensure no deprecated configuration elements used.

        IMPORTANT:
        Do not create any non-configuration files (Do not include README).
        You are allowed to create terraform configuration files under the <project_base>/airun/terraform.
        It is forbidden to create / modify / delete files outside of <project_base>/airun directory.
        It is strictly prohibited to create / modify / delete any of the existing aws resources through AWS tool, it can only be used to observe.
      next:
        state_id: end
```
4. Click **Create Workflow** or **Run**.
5. Provide a workflow name as prompted and adjust any parameters if necessary.
6. Start workflow and monitor execution from console.
7. When finished, retrieve generated Terraform files from `airun/terraform` directory.

---

#### Step 3: Review Outputs

Upon successful completion, following files are created or updated in `airun/terraform/`:
- `lambda.tf` — Terraform resource definitions for each generated Lambda function.
- `s3.tf` — Terraform configuration for S3 buckets required for Lambda code storage.

These artifacts are compatible with further infrastructure automation and deployable with your standard Terraform 
procedures.

---

#### Step 4: Next Steps

- Terraform configuration files are required inputs for database module validation (if your app uses DynamoDB) and 
final deployment steps.
- Continue with DynamoDB config validation (if applicable) or proceed directly to Terraform deployment.

---

### Additional Notes

- Only files in `airun/terraform` directory are changed; your core source and IaC files outside workspace 
remain intact.
- If Lambda archives or packaging status change, repeat this step for updated configuration.
- Review all generated Terraform code for your organization's compliance and best practices before applying in live 
environments.

## Module DynamoDB

Module DynamoDB step is intended for workflows where Lambda functions interact with AWS DynamoDB tables. This stage 
automates validation and correction of your Terraform DynamoDB configuration based on actual Lambda code 
requirements, ensuring database schemas in your infrastructure as code remain aligned with your application logic.

---

### Prerequisites

- Successful completion of Terraform Lambda Config step.
- `airun/lambdas/build_info.json` must be available.
- All generated Lambda source directories must be present in `airun/lambdas/`.
- **Bash shell**, **Terraform**, **jq**, **[nhrun](../resources/nhrun)**, and **[nhcheck](../resources/nhcheck)** 
must be installed and available in your `PATH`.
- Workflow modifies only DynamoDB-related sections under `airun/terraform`; it does not change other infrastructure 
resources.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Verify that DynamoDB-related Lambda functions and their build info are accessible.

---

#### Step 2: Launch Module DynamoDB Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Log in to EPAM AI/Run™ for AWS.
2. Navigate to **Workflows** and select **Templates** tab.
3. Find and select `[SERVERLESS][MODULE][5.1] DynamoDB Terraform Configuration Fixer`. Verify template content:
```yaml
slug: amna-serverless-05-01-module-dynamodb
name: "[SERVERLESS][MODULE][5.1] DynamoDB Terraform Configuration Fixer"
description: |
  Automatically fixes DynamoDB configuration mismatch.
  Requires data from "[SERVERLESS][3] Lambda Builder" workflow execution.
  
  This module should be omitted if the project doesn't have database.
  
  This workflow is an optional part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: aws_terraform_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert DevOps engineer experienced in configuring AWS resources, with the strong knowledge of Terraform.
        You have an access to local project and ability to run tools.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is observe.*
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines
        - name: AWS

  tools:
    - id: read_bootstrap_tool
      tool: _read_bootstrap_file
      toolset: Plugin
      trace: true

  states:
    - id: dynamodb_module_read_lambdas_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/build_info.json
      next:
        state_id: dynamodb_module_fixer
        iter_key: _

    - id: dynamodb_module_fixer
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to validate the DynamoDB schemas 
        presented AWS Lambda function located at the <project_base>/airun/lambdas/ directory
        and corresponding terraform configuration avaliable in the <project_base>/airun/terraform/ directory.

        Identify all issues present and fix the terraform configuration if found.
        Do mot modify any other resource terraform configurations.

        IMPORTANT:
        You are not allowed to create / modify / delete any files except those in <project_base>/airun/terraform/ directory.
        You are not allowed to create / modify / delete ANY resoures in the AWS account using tools.
      next:
        state_id: end

```
4. Click **Create Workflow** or **Run**.
5. Assign a workflow name as needed.
6. Adjust parameters if required.
7. Start workflow and monitor status in console.
8. On completion, retrieve `dynamodb.tf` from `airun/terraform`.

---

#### Step 3: Review Outputs

Upon completion:
- `airun/terraform/dynamodb.tf` will contain updated Terraform resource definitions aligned with your Lambda code usage 
patterns.
- Only DynamoDB-related resources are affected; all other Terraform files remain unchanged.

---

#### Step 4: Next Steps

- Updated Terraform DynamoDB configuration can now be used in deployment stage.
- Continue to Terraform deployment to provision and verify all AWS resources.

---

### Additional Notes

- This stage is only necessary if your migrated or generated Lambda functions actually use DynamoDB. If not, you may 
skip this workflow.
- Always review generated/modified `dynamodb.tf` for compliance and best practices before applying infrastructure changes.
- Workflow does not affect source code or unrelated infrastructure configuration.

## Terraform Deploy

Terraform Deploy stage executes deployment of all generated infrastructure code, provisioning AWS Lambda 
functions, API Gateway, DynamoDB tables, and associated resources. This step automates full Terraform 
lifecycle—`init`, `plan`, and `apply`, including error detection and correction through built-in process retries and 
human confirmation where required.

---

### Prerequisites

- All previous workflow stages complete: valid and up-to-date Terraform configuration must exist in `airun/terraform/`.
- **Terraform** must be installed and available in your PATH.
- **Bash shell**, **jq**, **[nhrun](../resources/nhrun)**, and **[nhcheck](../resources/nhcheck)** scripts must be 
installed.
- You must have valid AWS credentials with sufficient permissions to create and manage Lambda, API Gateway, DynamoDB, 
S3, and IAM resources.
- All workflow steps take place within `airun/terraform` directory, leaving your source code and core project 
files unchanged.

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Confirm all required Terraform files are present and reflect latest application state.

---

#### Step 2: Launch Terraform Deploy Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Access EPAM AI/Run™ for AWS platform in your browser.
2. Go to **Workflows** and select **Templates** tab.
3. Locate and select `[SERVERLESS][6] Terraform Deploy`. Verify template content:
```yaml
slug: amna-serverless-06-terraform-deploy
name: "[SERVERLESS][6] Terraform Deploy"
description: |
  Semi-automatically runs terraform init, terraform plan and terraform apply cycle, fixing encountered configuration issues.
  terraform_apply step requires manual confirmation, please, carefully review the suggested deployment plan before accepting it.
  Requires data from "[SERVERLESS][4] Terraform Lambda Config Generator" workflow execution.
  
  This workflow is a part of the split "[SERVERLESS] Automated Monolith to Serverless Migration" workflow.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  assistants:
    - id: aws_terraform_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert DevOps engineer experienced in configuring AWS resources, with the strong knowledge of Terraform.
        You have an access to local project and ability to run tools.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is observe.*
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines
        - name: AWS

    - id: command_runner
      exclude_extra_context_tools: true
      system_prompt: |
        You are an assistant designed to execute command line tools.
      tools:
        - name: _move_file
        - name: _list_directory
        - name: _directory_tree
        - name: _list_allowed_directories
        - name: _run_command
        - name: _show_security_rules

  states:
    - id: terraform_plan
      assistant_id: command_runner
      task: |
        You are given the task to run and observe terraform plan output.
        
        Steps to follow:
        1. Change working directory to airun/terraform.
        2. Execute "terraform init" command using tools within airun directory. 
        3. Execute "terraform plan -no-color" command using tools within airun directory, skip this step if terraform init command failed.
        4. Respond with a valid JSON.
        
        Output schema:
        {
          "success": "Boolean true | false. If terraform plan command executed without errors or warnings return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications.",
          "executedCommand": "Return the last executed command."
        }
        
        IMPORTANT:
        Do not try to fix any issues appeared while running terraform commands.
        *You MUST provide a valid JSON output only, without any decoration and thoughts.*
      output_schema: |
        {
          "success": "Boolean true | false. If terraform plan command executed without errors or warnings return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications.",
          "executedCommand": "Return the last executed command."
        }
      next:
        condition:
          expression: success == True
          then: terraform_apply
          otherwise: terraform_fixer

    - id: terraform_apply
      assistant_id: command_runner
      wait_for_user_confirmation: true
      task: |
        You are given the task to run and observe terraform apply output.
    
        Follow these steps to accomplish the task:
        1. Change working directory to airun/terraform.
        2. Execute ```nhrun terraform apply -no-color -auto-approve``` command using _run_command tool.
        3. Using output of the previous command identify PID_FILENAME and LOG_FILENAME from it's output.
        4. Execute ```nhcheck <PID_FILENAME>``` to identify if the process is already finished. Retry this step if not. Do not try using other commands when timed out it is expected to happen.
        5. Read LOG_FILENAME when process finishes.
        6. Analyse log file and identify if there were any errors.
        7. Respond with a valid JSON.
        
        Output format:
        {
          "success": "Boolean true | false. If process finished without any errors return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications."
        }
        
        IMPORTANT:
        Do not try to fix any issues appeared in log file.
        You should not produce any user-readable output as the user is unlikely to monitor your actions in real-time.
        *You MUST provide a valid JSON output only, without any decoration and thoughts.*
      output_schema: |
        {
          "success": "Boolean true | false. If process finished without any errors return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications."
        }
      next:
        condition:
          expression: success == True
          then: end
          otherwise: terraform_fixer

    - id: terraform_fixer
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to fix issues appeared while running the Terraform.
        Terraform configuration is stored under the <project_base>/airun/terraform directory.
        Analyse provided log and implement changes to address found errors.

        IMPORTANT:
        You are not allowed to create new directories or any non terraform files.
        Implement changes without new files creation if possible.
        Do not create temporary files, modify existing terraform configuration instead.
      next:
        include_in_llm_history: false
        state_id: terraform_plan
```
4. Click **Create Workflow** or **Run.**
5. Assign a workflow name, verify parameters, and execute workflow.
6. Monitor deployment steps (init, plan, apply) as reported by console UI.
7. Manual confirmation will be required before `terraform apply` is executed—follow onscreen prompts.

---

### Step 3: Review Outputs

Upon successful execution:
- Your AWS resources (Lambda, API Gateway, DynamoDB, S3, etc.) will be provisioned and available for use.
- Terraform state and logs are stored in `airun/terraform`.

Monitor workflow log and your AWS account for creation results and resource status.

---

#### Step 4: Next Steps

- After successful deployment, your serverless infrastructure is live and ready for validation or integration testing.
- If changes are required, update prior stages and rerun pipeline as needed.

---

### Additional Notes

- This deployment step includes automatic error detection and offers opportunity to resolve standard Terraform 
errors via fixer flow.
- Manual approval is mandatory where workflow applies infrastructure changes for safety and compliance reasons.
- Only files and state under `airun/terraform` are changed—core source and infrastructure as code in your repository 
remain untouched.

# All-in-One Workflow Description

All-in-One workflow is a comprehensive orchestration template that executes all migration and provisioning steps in
a single, automated pipeline. It combines project discovery, Lambda code generation, API Gateway and infrastructure 
configuration, build, packaging, optional DynamoDB validation, and full deployment. This end-to-end approach is  
recommended for teams seeking a zero-touch migration or for use in continuous integration and delivery pipelines.

---

### Prerequisites

- All tools and dependencies for individual steps must be available, including:
  - **Bash shell**, **Terraform**, **jq**, **[nhrun](../resources/nhrun)**, **[nhcheck](../resources/nhcheck)** in 
system `PATH`
  - Valid AWS credentials with permissions for Lambda, API Gateway, DynamoDB, S3, and IAM
- Project source code must be present in your working directory
- Sufficient local storage/repo access to write outputs to `airun/` workspace
- Follow system- or organization-specific onboarding steps if required; refer to "General Requirements" for setup 
details

---

### Step-by-Step Guide

#### 1. Grant access for CodeMie to you local file system

[Follow these steps in General Requirements section](#setting-codemie-plugins-and-enabling-access-to-your-local-files)

Ensure your code is prepared and all necessary workflow prerequisites have been met.

---

### Step 2: Launch All-in-One Workflow

Use EPAM AI/Run™ for AWS platform Web Console

1. Log into EPAM AI/Run™ for AWS web platform.
2. Go to **Workflows** section and select **Templates** tab.
3. Search for and select `[SERVERLESS] Automated Monolith to Serverless Migration`. Verify template content:
```yaml
slug: amna-serverless99-all-in-one
name: "[SERVERLESS] Automated Monolith to Serverless Migration"
description: |
  Automatically analyzes current project, migrates suitable parts to AWS Lambdas and generates Terraform api-gateway configuration.
mode: Sequential
execution_config:
  enable_summarization_node: false
  max_concurrency: 1

  tools:
    - id: read_bootstrap_tool
      tool: _read_bootstrap_file
      toolset: Plugin
      trace: true

  assistants:
    - id: aws_lambda_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert Software Developer, experienced in monolith to serverless migrations 
        with strong knowledge of AWS Lambdas, DynamoDB, API gateways and other AWS services.
        
        You have an access to local project and ability to run tools.
        
        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines

    - id: aws_terraform_expert
      exclude_extra_context_tools: true
      system_prompt: |
        You are an expert DevOps engineer experienced in configuring AWS resources, with the strong knowledge of Terraform.
        You have an access to local project and ability to run tools.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        IMPORTANT:
        You are not allowed to modify any of the project files under any circumstances.
        The only files you can edit are under airun directory.
        If there is no airun directory, create one under the root of a project.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is observe.*
      tools:
        - name: _read_file
        - name: _read_multiple_files
        - name: _write_file
        - name: _edit_file
        - name: _create_directory
        - name: _list_directory
        - name: _directory_tree
        - name: _move_file
        - name: _search_files
        - name: _get_file_info
        - name: _list_allowed_directories
        - name: _append_structured_file
        - name: _search_files_by_regex
        - name: _read_file_lines
        - name: AWS

    - id: command_runner
      exclude_extra_context_tools: true
      system_prompt: |
        You are an assistant designed to execute command line tools.
      tools:
        - name: _append_structured_file
        - name: _move_file
        - name: _list_directory
        - name: _directory_tree
        - name: _list_allowed_directories
        - name: _run_command
        - name: _show_security_rules
  states:
    - id: analysis
      assistant_id: aws_lambda_expert
      task: |
        You are given the task to analyse the project and identify which components can be migrated to AWS lambdas and which can't.

        If component is suitable/feasible for migration to lambda     - use _append_structured_file tool and write information about the file to <project_base>/airun/migratable.json
        If component is NOT suitable/feasible for migration to lambda - use _append_structured_file tool and write information about the file to <project_base>/airun/non_migratable.json

        The output format is:
        {
          "component_name": "Name of a desired lambda. Use Pascal case for the name.",
          "description": "Short description of it's functionality",
          "sources": [ "List of source files, which contains all the code needed by the new lambda." ],
          "additional_information": "Any relevant information about the component."
          "is_migratable": "true / false"
          "reasoning": "A few sentences why you believe this component is suitable or unsuitable for AWS Lambda migration"
          "language": "The most suitable language for the lambda conversion. (e.g. Python)",
          "endpoint_uri": "Endpoint root URI (e.g. /admin)"
        }
      next:
        state_ids:
          - migratable

    - id: migratable
      tool_id: read_bootstrap_tool
      tool_args:
        path: migratable.json
      next:
        include_in_llm_history: false
        state_id: lambda_writer
        iter_key: _

    - id: lambda_writer
      assistant_id: aws_lambda_expert
      task: |
        You are given a component and where it is stored. You must convert it to AWS Lambda written in {{language}}.
        Read the file, do the conversion and output the resulting {{language}} text.

        Input parameters and output must be valid JSONs.

        Create the only file with {{language}} AWS lambda code.
        Your output will be passed to specialized assistant that will use AWS API to create Lambda from the code
        fragment you provided.

        If you successfully created lambda - use _append_structured_file tool and write information about the lambda to <project_base>/airun/lambdas/lambda_info.json
        Using the following output format:
        {
          "lambda_name": "{{component_name}}",
          "component_root_dir": "Generated lambda root directory (e.g. <project_base>/airun/lambdas/{{component_name}})",
          "language": "{{language}}",
          "description": "Short description of it's functionality",
          "endpoint_uri": "{{endpoint_uri}}",
        }

        IMPORTANT:
        You are allowed to create lambda files under the <project_base>/airun/lambdas/{{component_name}},
        and you are not allowed to modify or create any files outside of the directory.
        Do not create build script files, readme files or any other non-required files.
      output_format: |
        {
          "lambda_name": "{{component_name}}",
          "component_root_dir": "Generated lambda root directory (e.g. <project_base>/airun/lambdas/{{component_name}})",
          "language": "{{language}}",
          "description": "Short description of it's functionality",
          "endpoint_uri": "{{endpoint_uri}}",
        }
      next:
        state_id: read_lambdas_info

    - id: read_lambdas_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/lambda_info.json
      next:
        include_in_llm_history: false
        state_id: api_gateway_config_generator
        iter_key: _

    - id: api_gateway_config_generator
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to update Terraform configuration files using tools with an api-gateway configuration for the provided lambda.
        You are also allowed to use AWS tool to view aws resources. Avoid using example resources or names, use actual resources instead.

        Follow these steps to accomplish the task:
        1. Read existing terraform configuration stored at <project_base>/airun/terraform.
        2. Read required to be added lambda.
        3. Identify available aws regions and availability zones, use only one of each.
        4. Update Terraform configuration for api-gateway, ensuring all lambda endpoints are added.
        5. Read all of the terraform files and verify your solution:
          - Ensure all resources used in api-gateway are present in Terraform configuration.
          - Check there are no resource duplicates.
          - Ensure no deprecated arguments used.

        IMPORTANT:
        Do not include anything besides api-gateway configuration, other parts will be added by different agent.
        Do not create any non-configuration files (Do not include README).
        Keep file structure clean. Use one file for one resource type.
        *You ARE NOT allowed to modify or create any of AWS resources, the only thing you can do is to observe.*
        You are not allowed to create / modify / delete any file outside of the <project_base>/airun/terraform directory.
      next:
        include_in_llm_history: false
        state_id: build_sequence_enricher

    - id: build_sequence_enricher
      assistant_id: aws_lambda_expert
      task: |
        You are given the task to enrich each element of json array with the field "build_sequence".
        Substitute $variable with actual values taken from the enriching element.
    
        Your steps must be the following:
        1. Read <project_path>/airun/lambdas/lambda_info.json file.
        2. Do for each element:
          - Identify the language field.
          - Enrich the element with the "build_sequence" field according to the language value.
    
        Python build sequence must be exactly the following (with substituted variables):
        "build_sequence": [
          "mkdir package",
          "pip install -r requirements.txt -t package",
          "cd package && zip -r $component_root_dir/$lambda_name.zip .",
          "zip $lambda_name.zip lambda_function.py"
        ]
    
        Java build sequence must be exactly the following:
        "build_sequence": ["mvn package"]
    
        You should observe / modify only the <project_path>/airun/lambdas/lambda_info.json file.
        You cannot read / modify / create / delete any other file or directory.
      next:
        state_id: read_lambdas_enriched_info

    - id: read_lambdas_enriched_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/lambda_info.json
      next:
        include_in_llm_history: false
        state_id: lambda_builder
        iter_key: _

    - id: lambda_builder
      assistant_id: command_runner
      task: |
        1. Build lambda using {{build_sequence}}, from {{component_root_dir}}. Use _run_command tool to accomplish this task.
        2. Create <project_base>/airun/lambdas/archives directory.
        3. Move lambda archive to the airun/lambdas/archives directory.
        4. Clean up.

        Use _append_structured_file tool and write information about the lambda to airun/lambdas/build_info.json
        Using the following output format:
        {
          "lambda_name": "{{component_name}}",
          "lambda_archive_path": "Path to the archive, containing built lambda.",
          "description": "Short description of it's functionality",
          "endpoint_uri": "{{endpoint_uri}}",
          "success": "Displays if archive with lambda was created successfully, true | false."
        }
      next:
        state_id: read_lambdas_build_info

    - id: read_lambdas_build_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/build_info.json
      next:
        include_in_llm_history: false
        state_id: terraform_lambda_config_writer

    - id: terraform_lambda_config_writer
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to generate configuration for lambda deployment.
        Add only necessary resources. If lambda can be deployed without the resource then it shouldn't be present in configuration.

        Follow these steps to accomplish the task:
        1. Examine all terraform configuration files before trying to change them.
        2. Create *<project_base>/airun/terraform* directory if not present and use it as a working directory. 
        3. Add configuration for the new s3 bucket to store lambdas, skip this step if bucket is already described in terraform configuration.
        4. Generate lambdas configuration. Use *AWS* tool to gather any information about the account.
        5. Verify generated configuration.
          - There should be no mocked resources in the result.
          - Check there are no resource duplicates.
          - Ensure no deprecated configuration elements used.

        IMPORTANT:
        Do not create any non-configuration files (Do not include README).
        You are allowed to create terraform configuration files under the <project_base>/airun/terraform.
        It is forbidden to create / modify / delete files outside of <project_base>/airun directory.
        It is strictly prohibited to create / modify / delete any of the existing aws resources through AWS tool, it can only be used to observe.
      next:
        state_ids: [ dynamodb_module_read_lambdas_info ]

    - id: dynamodb_module_read_lambdas_info
      tool_id: read_bootstrap_tool
      tool_args:
        path: lambdas/build_info.json
      next:
        include_in_llm_history: false
        state_id: dynamodb_module_fixer
        iter_key: _

    - id: dynamodb_module_fixer
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to validate the DynamoDB schemas 
        presented AWS Lambda function located at the <project_base>/airun/lambdas/ directory
        and corresponding terraform configuration avaliable in the <project_base>/airun/terraform/ directory.

        Identify all issues present and fix the terraform configuration if found.
        Do mot modify any other resource terraform configurations.

        IMPORTANT:
        You are not allowed to create / modify / delete any files except those in <project_base>/airun/terraform/ directory.
        You are not allowed to create / modify / delete ANY resoures in the AWS account using tools.
      next:
        include_in_llm_history: false
        state_id: terraform_plan

    - id: terraform_plan
      assistant_id: command_runner
      task: |
        You are given the task to run and observe terraform plan output.
        
        Steps to follow:
        1. Change working directory to airun/terraform.
        2. Execute "terraform init" command using tools within airun directory. 
        3. Execute "terraform plan -no-color" command using tools within airun directory, skip this step if terraform init command failed.
        4. Respond with a valid JSON.
        
        Output schema:
        {
          "success": "Boolean true | false. If terraform plan command executed without errors or warnings return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications.",
          "executedCommand": "Return the last executed command."
        }
        
        IMPORTANT:
        Do not try to fix any issues appeared while running terraform commands.
        *You MUST provide a valid JSON output only, without any decoration and thoughts.*
      output_schema: |
        {
          "success": "Boolean true | false. If terraform plan command executed without errors or warnings return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications.",
          "executedCommand": "Return the last executed command."
        }
      next:
        condition:
          expression: success == True
          then: terraform_apply
          otherwise: terraform_fixer

    - id: terraform_apply
      assistant_id: command_runner
      wait_for_user_confirmation: true
      task: |
        You are given the task to run and observe terraform apply output.
    
        Follow these steps to accomplish the task:
        1. Change working directory to airun/terraform.
        2. Execute ```nhrun terraform apply -no-color -auto-approve``` command using _run_command tool.
        3. Using output of the previous command identify PID_FILENAME and LOG_FILENAME from it's output.
        4. Execute ```nhcheck <PID_FILENAME>``` to identify if the process is already finished. Retry this step if not. Do not try using other commands when timed out it is expected to happen.
        5. Read LOG_FILENAME when process finishes.
        6. Analyse log file and identify if there were any errors.
        7. Respond with a valid JSON.
        
        Output format:
        {
          "success": "Boolean true | false. If process finished without any errors return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications."
        }
        
        IMPORTANT:
        Do not try to fix any issues appeared in log file.
        You should not produce any user-readable output as the user is unlikely to monitor your actions in real-time.
        *You MUST provide a valid JSON output only, without any decoration and thoughts.*
      output_schema: |
        {
          "success": "Boolean true | false. If process finished without any errors return true, otherwise false",
          "log": "Exactly the output of the command execution log without ANY modifications."
        }
      next:
        condition:
          expression: success == True
          then: end
          otherwise: terraform_fixer

    - id: terraform_fixer
      assistant_id: aws_terraform_expert
      task: |
        You are given the task to fix issues appeared while running the Terraform.
        Terraform configuration is stored under the <project_base>/airun/terraform directory.
        Analyse provided log and implement changes to address found errors.

        IMPORTANT:
        You are not allowed to create new directories or any non terraform files.
        Implement changes without new files creation if possible.
        Do not create temporary files, modify existing terraform configuration instead.
      next:
        include_in_llm_history: false
        state_id: terraform_plan
```
4. Click **Create Workflow** or **Run**.
5. Assign a descriptive workflow name if necessary.
6. (Optionally) Adjust any parameters for workflow run.
7. Start workflow and monitor completion, tracking progress and outputs of each stage in pipeline.
8. Once finished, collect all output artifacts (discovery lists, Lambda packages, build reports, Terraform and 
deployment results) from `airun/` workspace directories.

---

### Step 3: Review Outputs

When all-in-one workflow completes:

- All stages (discovery, Lambda code generation, API Gateway, Lambda packaging, DynamoDB config, and deployment) will 
be executed end-to-end.
- All output files, including migration audit artifacts, Lambda packages, generated configuration, and logs, will be 
created in `airun/` subdirectories.
- Complete targeted serverless infrastructure will be deployed into your AWS environment if deployment step is 
confirmed.

---

### Step 4: Next Steps

- Upon successful pipeline execution, validate your Lambda endpoints, API Gateway configuration, and data integrations 
using your usual testing or QA procedures.
- For iterative development, revert to step-by-step execution or modify your pipeline as needed for additional 
customization or re-runs.

---

### Additional Notes

- Entire migration process is run as a single workflow, automatically passing artifacts and context between stages.
- This workflow includes advanced error handling: if any stage fails, system will attempt to resolve issues 
automatically, but manual intervention may be required.
- No source files outside of `airun/` folder are ever modified.
- Best used for production migrations, CI/CD scenarios, or proof-of-concept full project automations.
