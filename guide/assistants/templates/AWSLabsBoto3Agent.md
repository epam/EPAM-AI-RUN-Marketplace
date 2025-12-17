# AWSLabs boto3 Agent: General AWS Assistant

## Overview

The **AWSLabs boto3 Agent** is a general-purpose AWS assistant that leverages the official AWS Labs MCP server to interact with AWS services. Unlike community-maintained alternatives, this assistant uses the officially supported `awslabs.aws-api-mcp-server` from [AWS Labs MCP Repository](https://github.com/awslabs/mcp/tree/main/src/aws-api-mcp-server).

This assistant provides comprehensive AWS resource management capabilities through boto3, supporting both querying and modification operations across all AWS services supported by the boto3 package.

**Assistant Slug**: `amna-aws-boto3-agent`

---

## Key Characteristics

### Boto3-Powered Operations
The assistant utilizes the official AWS Labs MCP server, which provides validated AWS CLI command execution backed by boto3. This ensures compatibility with all AWS services and operations supported by the boto3 SDK.

### Available Tools
The assistant has access to two primary tools:

1. **`call_aws*`**: Execute validated AWS CLI commands directly
2. **`suggest_aws_commands*`**: Suggest likely AWS CLI commands based on natural language requests

### Operational Behavior
The assistant follows strict operational rules:

1. **Always Query First**: Must use the `call_aws*` tool for every AWS-related prompt to ensure working with current data
2. **No Cached Responses**: All AWS information must be freshly retrieved via the MCP server
3. **Modification Confirmation**: Always asks for explicit permission before making changes to AWS resources
4. **Query Autonomy**: Executes read-only queries without requiring approval

---

## Response Formatting

### Tabular Presentation
When data readability benefits from structured presentation, the assistant automatically formats responses as tables.

### Clickable Links
For any created or modified AWS resources, the assistant includes clickable console links for easy verification and access.

---

## MCP Server Configuration

To use this assistant, you need to configure the AWS Labs MCP server in your Codemie plugins configuration file.

### Configuration Location
Add the following to `~/.codemie/config.json`:

```json
{
  "mcpServers": {
    "awslabs.aws-api-mcp-server": {
      "command": "uvx",
      "args": [
        "awslabs.aws-api-mcp-server@latest"
      ],
      "env": {
        "AWS_API_MCP_PROFILE_NAME": "your-aws-profile",
        "AWS_REGION": "us-east-1"
      },
      "disabled": false,
      "autoApprove": []
    }
  }
}
```

### Configuration Parameters

- **command**: `uvx` - UV package runner for automatic installation and execution
- **args**: `["awslabs.aws-api-mcp-server@latest"]` - Automatically uses the latest version
- **env.AWS_API_MCP_PROFILE_NAME**: Your AWS CLI profile name (configured via `aws configure`)
- **env.AWS_REGION**: Default AWS region for operations
- **disabled**: Set to `false` to enable the server
- **autoApprove**: Array of tools that don't require approval (leave empty for security)

> **Note**: Replace `"your-aws-profile"` with your actual AWS CLI profile name and adjust the region as needed for your environment.

---

## Usage Context

### Prerequisites
- **AWS Labs MCP Server**: Installed via UV package manager (automatic with `uvx`)
- **AWS Credentials**: Properly configured AWS CLI profile with appropriate permissions
- **UV Package Manager**: Required for running the MCP server

### Supported AWS Services
The assistant can interact with all AWS services supported by boto3, including but not limited to:

**Compute**: EC2, Lambda, ECS, EKS, Batch, Lightsail  
**Storage**: S3, EBS, EFS, FSx, Storage Gateway  
**Database**: RDS, DynamoDB, ElastiCache, Neptune, DocumentDB  
**Networking**: VPC, Route53, CloudFront, API Gateway, ELB  
**Security**: IAM, Secrets Manager, KMS, Certificate Manager, WAF  
**Monitoring**: CloudWatch, CloudTrail, X-Ray, EventBridge  
**DevOps**: CodePipeline, CodeBuild, CodeDeploy, CloudFormation  
**Analytics**: Athena, EMR, Kinesis, Glue, QuickSight  
**Machine Learning**: SageMaker, Comprehend, Rekognition, Translate  
**Application Integration**: SNS, SQS, Step Functions, AppSync  

---

## Operational Workflow

### For Query Operations
1. User requests AWS resource information
2. Assistant uses `call_aws*` tool to retrieve current data
3. Assistant formats and presents the response (with tables if beneficial)
4. No approval required for read-only operations

### For Modification Operations
1. User requests AWS resource changes
2. Assistant clarifies the intended modification
3. Assistant explicitly asks for user permission
4. Upon approval, assistant uses `call_aws*` tool to execute changes
5. Assistant provides confirmation with clickable links to modified resources

### For Command Discovery
1. User describes what they want to do in natural language
2. Assistant uses `suggest_aws_commands*` to get command suggestions
3. Assistant presents suggested commands with explanations
4. User can choose to execute or refine the suggestions

---

## Security Considerations

### Permission-Based Access
The assistant's capabilities are limited by the IAM permissions associated with the configured AWS profile. It cannot perform actions beyond what the AWS credentials allow.

### Modification Safeguards
All modification operations require explicit user confirmation, preventing accidental changes to AWS infrastructure.

---

## Example Use Cases

### Resource Inspection
- List EC2 instances with their states and IP addresses
- View S3 bucket contents and permissions
- Check RDS database configurations
- Inspect Lambda function settings

### Infrastructure Management
- Create and configure new AWS resources
- Modify existing resource settings
- Delete or terminate resources
- Update security groups and IAM policies

### Monitoring and Troubleshooting
- Check CloudWatch metrics and alarms
- Review CloudTrail logs
- Analyze resource utilization
- Investigate connectivity issues

### Automation Support
- Discover appropriate AWS CLI commands for tasks
- Generate command templates for common operations
- Validate command syntax before execution
- Build automation scripts with suggested commands

---

## Best Practices

### When Using This Assistant
- Always verify the AWS profile and region before making modifications
- Review suggested changes carefully before approving
- Use the command suggestion feature to learn AWS CLI syntax
- Request tabular output for comparing multiple resources
- Leverage clickable links to verify changes in the AWS Console

### What to Avoid
- Don't rely on cached information; the assistant always queries fresh data
- Don't skip the confirmation step for modifications
- Don't assume permissions; verify IAM policies if operations fail

---

## Related Documentation

- **AWS Labs MCP Server**: [GitHub Repository](https://github.com/awslabs/mcp/tree/main/src/aws-api-mcp-server)
- **Boto3 Documentation**: [AWS SDK for Python](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- **AWS CLI Reference**: [AWS Command Line Interface](https://docs.aws.amazon.com/cli/)
- **UV Package Manager**: [UV Documentation](https://github.com/astral-sh/uv)

---

## Comparison with Community Version

This assistant uses the **official AWS Labs** MCP server, which differs from the community-maintained `mcp-server-aws-resources-python`:

- **Official Support**: Maintained by AWS Labs
- **Simplified Installation**: Uses UV package manager with automatic updates
- **Command Suggestions**: Unique natural language to CLI command translation
- **Validated Execution**: Built-in command validation before execution
- **Different Configuration**: Uses `AWS_API_MCP_PROFILE_NAME` instead of `AWS_PROFILE`

Choose this version if you prefer official AWS tooling and want the command suggestion feature.
