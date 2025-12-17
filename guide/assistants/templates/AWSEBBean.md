# Bean: AWS Elastic Beanstalk Agentic Assistant

## Overview
The **Bean** assistant is an AI agent designed to work with AWS Elastic Beanstalk deployment and teardown workflows. It operates within a constrained environment where it can read and modify application configuration files while executing deployment scripts through background processes.

## Purpose
This assistant serves as the execution engine for the **BeanStalker** and **BeanDestroyer** workflows, handling:
- Application configuration analysis and setup
- Procfile generation and modification
- Platform detection and selection
- Background script execution and monitoring
- Infrastructure deployment and teardown orchestration

## Key Characteristics

### Constrained Operations
The assistant is designed with strict operational boundaries:
- **Modifiable Files**: Only application-specific files such as `Procfile`, `.ebextensions/*.config`, and similar configuration files
- **Protected Files**: Deployment scripts (`deploy.sh`, `cleanup.sh`) and infrastructure definitions remain unaltered
- **Execution Model**: All deployment operations run as background processes using `run_bg` and `check_bg` helper scripts

### Available Tools
The assistant has access to two MCP server toolkits:
1. **filesystem**: For reading, writing, and managing files within the allowed directory
2. **cli-mcp-server**: For executing shell commands in the deployment environment

### Autonomous Operation
The assistant executes tasks **without requiring approvals or confirmations**, following a principle of minimal change to existing configurations.

## Platform Support
The assistant automatically detects and selects appropriate AWS Elastic Beanstalk platforms based on application file extensions:

| File Extension | Platform |
|---------------|----------|
| `.py` | `python-3.11` |
| `.java`, `.jar` | `corretto-17` |
| `.war` | `tomcat-10-corretto-17` |
| `.js` | `Node.js-20` |
| `.php` | `PHP-8.2` |
| `.rb` | `ruby-3.2` |
| `.go` | `go-1` |
| `Dockerfile` | `docker` |
| `.cs` | `64bit-amazon-linux-2023-v3.5.3-running-.net-8` |

## Usage Context

### Prerequisites
Before using this assistant, you must complete the BeanStalker environment setup. See:
- **Setup Instructions**: `guide/workflows/templates/AWSElasticBeanstalkDeploymentAutomation.md`
- **Required Resources**: `guide/workflows/resources/beanstalk-workflow/`

### Integration with Workflows
This assistant is designed to be used exclusively with:
1. **BeanStalker Workflow** (`amna-aws-eb-beanstalker-deploy`) - For deployment automation
2. **BeanDestroyer Workflow** (`amna-aws-eb-beandestroyer-teardown`) - For infrastructure teardown

For detailed workflow execution steps, configuration requirements, and operational procedures, refer to:
- `guide/workflows/templates/AWSElasticBeanstalkDeploymentAutomation.md`

### Configuration Requirements
The assistant requires:
- **ALLOWED_DIR** or **FILE_PATHS** environment variable pointing to the BeanStalker working directory
- Active MCP servers: `filesystem` and `cli-mcp-server` with access to the working directory
- Properly configured `codemie-plugins` connection

## Operational Behavior

### Background Process Management
The assistant uses a two-script pattern for long-running operations:
- **`run_bg`**: Starts deployment/cleanup scripts in the background, returns a PID
- **`check_bg`**: Monitors background process status using the PID

This allows workflows to poll for completion without blocking execution.

### File Modification Strategy
When modifying configuration files, the assistant:
1. Analyzes existing infrastructure definitions
2. Makes minimal necessary changes
3. Preserves deployment script integrity
4. Ensures compatibility with selected platform

### Error Handling
If deployment or cleanup scripts fail to start, the assistant:
1. Sets appropriate status flags (`deployment_started: false` or `cleanup_started: false`)
2. Attempts to diagnose the failure
3. Reports the problem in structured JSON output
4. Allows workflows to terminate gracefully

## Related Documentation
- **Workflow Setup & Execution**: `guide/workflows/templates/AWSElasticBeanstalkDeploymentAutomation.md`
- **Infrastructure Resources**: `guide/workflows/resources/beanstalk-workflow/`
- **BeanStalker Workflow**: See workflow template `amna-aws-eb-beanstalker-deploy`
- **BeanDestroyer Workflow**: See workflow template `amna-aws-eb-beandestroyer-teardown`

## Categories
- DevOps
- Migration & Modernization
