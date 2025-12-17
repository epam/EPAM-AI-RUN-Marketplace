# AWS boto3 Agent: General AWS Assistant

## Overview
The **AWS boto3 Agent** is a general-purpose AI assistant for interacting with AWS services through the boto3 Python SDK. It leverages the `mcp-server-aws-resources-python` MCP server to enable comprehensive AWS resource querying and modification capabilities.

## Purpose
This assistant serves as a versatile AWS operations interface, handling:
- Real-time AWS resource queries across all boto3-supported services
- AWS infrastructure modifications and updates
- Resource inspection and monitoring
- AWS environment management and configuration
- Interactive AWS operations with user confirmation for modifications

## Key Characteristics

### Boto3-Powered Operations
The assistant utilizes the full capabilities of the AWS boto3 SDK through the MCP server:
- **MCP Server**: [`mcp-server-aws-resources-python`](https://github.com/baryhuang/mcp-server-aws-resources-python)
- **Coverage**: All AWS services and operations supported by boto3
- **Execution Model**: Python code snippets executed directly against AWS APIs

### Available Tools
The assistant has access to:
- **`_aws_resources_query_or_modify_*`**: Execute Python boto3 code snippets to query or modify AWS resources in real-time

### Operational Behavior
The assistant follows strict operational rules:
1. **Always Query First**: Must use the boto3 tool for every AWS-related prompt to ensure up-to-date data
2. **No Cached Responses**: Never responds to AWS queries without first executing a live boto3 call
3. **Modification Confirmation**: Always asks for user permission before making changes to AWS resources
4. **Query Autonomy**: Executes read-only queries without requiring approval

## Response Formatting

### Table Presentation
When query results benefit from structured presentation, the assistant automatically formats responses as tables for improved readability.

### Clickable Links
For any created or modified AWS resources, the assistant includes:
- Direct clickable links to AWS Console
- Easy access for verification and management
- Resource ARNs and identifiers

## Usage Context

### Prerequisites
Before using this assistant, ensure:
- **MCP Server Installation**: `mcp-server-aws-resources-python` is installed and configured
- **AWS Credentials**: Properly configured AWS credentials (via environment variables, AWS CLI config, or IAM roles)
- **Boto3 Access**: Python boto3 package is available in the MCP server environment

### MCP Server Configuration
The MCP server must be configured in your Codemie plugins configuration file (typically `~/.codemie/config.json`).

**Example Configuration:**
```json
"aws-boto3-server": {
  "command": "python",
  "args": [
    "/path/to/mcp-server-aws-resources-python/src/mcp_server_aws_resources/server.py"
  ],
  "transport": "stdio",
  "workingDir": "/path/to/mcp-server-aws-resources-python",
  "env": {
    "AWS_PROFILE": "your-aws-profile",
    "AWS_REGION": "us-east-1"
  }
}
```

**Configuration Parameters:**
- **command**: Python interpreter to use
- **args**: Path to the MCP server's main Python script
- **transport**: Communication method (use `stdio` for standard input/output)
- **workingDir**: Root directory of the MCP server installation
- **env.AWS_PROFILE**: AWS CLI profile name to use for credentials
- **env.AWS_REGION**: Default AWS region for operations

**Note**: Adjust the paths to match your local installation directory and set the AWS profile/region according to your AWS configuration.

### Supported AWS Services
The assistant can interact with any AWS service supported by boto3, including but not limited to:
- **Compute**: EC2, Lambda, ECS, EKS, Fargate
- **Storage**: S3, EBS, EFS, Glacier
- **Database**: RDS, DynamoDB, ElastiCache, Redshift
- **Networking**: VPC, Route53, CloudFront, API Gateway
- **Security**: IAM, Secrets Manager, KMS, Security Hub
- **Management**: CloudFormation, CloudWatch, Systems Manager
- **And many more**: Any service with boto3 support

## Operational Workflow

### Query Operations
1. User requests AWS resource information
2. Assistant executes boto3 query via MCP tool
3. Results are formatted (tables, lists, or structured output)
4. Response includes relevant resource identifiers and links

### Modification Operations
1. User requests AWS resource changes
2. Assistant identifies the modification intent
3. **Clarifies and asks for explicit permission**
4. Upon approval, executes boto3 modification code
5. Returns confirmation with clickable links to modified resources

## Security Considerations

### Permission-Based Access
The assistant operates within the constraints of:
- AWS credentials configured for the MCP server
- IAM policies attached to the credentials
- Service Control Policies (SCPs) if using AWS Organizations

### Modification Safeguards
- **Explicit Confirmation**: All destructive or modification operations require user approval
- **No Assumptions**: Never proceeds with changes based on implied consent
- **Clear Communication**: Always states what will be changed before execution

## Example Use Cases

### Resource Inspection
- List all EC2 instances in a region
- Check S3 bucket policies and permissions
- Review IAM roles and attached policies
- Inspect VPC configurations and security groups

### Infrastructure Management
- Create and configure new AWS resources
- Update existing resource configurations
- Tag resources for organization and cost tracking
- Modify security group rules and network ACLs

### Monitoring and Troubleshooting
- Query CloudWatch metrics and logs
- Check resource health and status
- Investigate configuration issues
- Analyze cost and usage patterns

### Automation Support
- Prepare boto3 code snippets for automation scripts
- Validate AWS API calls before implementation
- Test resource configurations interactively
- Prototype infrastructure changes safely

## Best Practices

### When Using This Assistant
1. **Be Specific**: Clearly state which AWS service, region, and resources you're interested in
2. **Review Before Approval**: Always review proposed changes before confirming modifications
3. **Use for Exploration**: Leverage the assistant to explore AWS services and their capabilities
4. **Verify Results**: Check provided links to confirm changes in the AWS Console

### What to Avoid
- Don't assume the assistant has cached AWS state (it always queries live)
- Don't approve modifications without understanding their impact
- Don't share sensitive data returned by queries in insecure channels

## Related Documentation
- **MCP Server Source**: [mcp-server-aws-resources-python](https://github.com/baryhuang/mcp-server-aws-resources-python)
- **AWS Boto3 Documentation**: [AWS SDK for Python (Boto3)](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html)
- **AWS Service Documentation**: [AWS Documentation](https://docs.aws.amazon.com/)

## Categories
- DevOps
- Migration & Modernization
