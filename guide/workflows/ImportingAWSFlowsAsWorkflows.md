# Installing AWS Flows as Workflows

## Overview

AWS Bedrock Flows allow you to create sophisticated AI workflows with multiple steps, conditions, and integrations. Install them into Codemie to execute your AWS-designed flows from conversations and parent workflows.

---

## Prerequisites

- AWS integration configured with valid credentials
- AWS Flow created and prepared in AWS Bedrock console
- Flow must have at least one Flow Alias in "PREPARED" status

---

## Understanding Flow Status

### Flow Status
- **PREPARED**: The flow is validated and ready to use (status is "Prepared")
- **Not Prepared**: The flow has validation errors or is not ready

⚠️ **Important**: You can only view details and install flows with "PREPARED" status. Flows with "Not Prepared" status will display an info badge but won't have a **More Info** button.

### Flow Alias Status
- **PREPARED**: The alias points to a numeric version (e.g., "1", "2", "3")
- **Not Prepared**: The alias points to DRAFT or has no valid version

ℹ️ **Note**: Each flow can have multiple aliases representing different versions or environments (dev, prod, etc.).

---

## Step-by-Step Installation Process

### Step 1: Navigate to AWS Flows

1. Go to **Settings** → **AWS Integration** in the left sidebar
2. Select **Flows**
3. You'll see a table listing all your AWS integrations

**Integration Table Shows:**
- **Setting Name**: Your integration name
- **Project**: Associated project
- **Entities**: List of available flows (up to 3 shown, with "..." if more exist)
- **Status**: Connection status or available entities

### Step 2: Select an Integration

1. Click on an integration row to view all available AWS flows for that integration
2. You'll see a list of all flows in your AWS account

**Flow List Shows:**
- Flow Name
- Flow Description
- Flow ID
- Status indicator (info badge for "Not Prepared", or **More Info** button for "PREPARED")

### Step 3: View Flow Details

1. Click **More Info** on a flow with "PREPARED" status
2. Review the flow information:
   - Flow configuration
   - Available aliases/versions
   - Flow structure and nodes
   - Last modified date

### Step 4: Choose an Alias

1. From the flow details view, you'll see all available aliases for this flow
2. Review the alias information:
   - Alias Name
   - Alias ID
   - Description
   - Last updated date
   - Installation status

**Alias Display:**
- Uninstalled aliases show an **Install** button
- Installed aliases show:
  - AI Run ID (the Codemie Workflow ID)
  - **Open in Codemie** button to navigate to the workflow
  - **Uninstall** button to remove the installation

⚠️ **Selection Rules:**
- You can only install aliases with "PREPARED" status
- Only aliases with numeric versions can be installed
- DRAFT versions are not available for installation
- Each alias installs as a separate workflow in Codemie
- You can install multiple versions/aliases of the same flow

### Step 5: Install the Alias

1. Click **Install** on your selected alias
2. The system will:
   - Create a new Workflow in Codemie
   - Link it to your AWS Flow Alias
   - Configure invocation settings
   - Display the AI Run ID once complete

3. After installation:
   - The **Install** button changes to show the AI Run ID
   - An **Open in Codemie** button appears to navigate directly to the workflow
   - An **Uninstall** button appears to remove the installation

### Step 6: Access Your Workflow

1. Click **Open in Codemie** to view your newly installed workflow
2. Or navigate to the **Workflows** page to find it in your workflows list

---

## Managing Installed Flows

### Viewing Installed Flows

From the flow details view, installed aliases are marked with:
- The AI Run ID displayed prominently
- Last updated date
- **Open in Codemie** button
- **Uninstall** button

### Uninstalling an Alias

1. From the flow details view, click **Uninstall** on an installed alias
2. Confirm the uninstallation in the popup:
   - Review the version information
   - Read the warning about deletion
   - Click **Uninstall** to confirm or **Cancel** to abort

⚠️ **Warning**: Uninstalling will permanently delete the workflow from Codemie. Any parent workflows or integrations using this flow will no longer work.

### Reinstalling an Alias

If you uninstall an alias, you can reinstall it at any time:
1. The **Install** button will reappear
2. Click **Install** to create a new workflow (with a new AI Run ID)
3. Note: This creates a completely new workflow; previous executions and configurations are not restored

---

## Using Installed Flows

### Standalone Execution

1. Go to **Workflows** → Select your installed flow
2. Click **Execute**
3. Provide required input parameters
4. View execution results and logs

### In Parent Workflows

1. Edit or create a workflow
2. Add a **Bedrock Flow Node**
3. Select your installed AWS Flow
4. Configure input mapping
5. The parent workflow will invoke your AWS Flow when reaching this node

### In Conversations

Some flows can be triggered from conversations:

1. Start a conversation
2. Use specific commands or triggers configured in your flow
3. The flow will execute and return results to the conversation

---

## Flow Input and Output

### Input Parameters

AWS Flows accept input in various formats:
- Simple text input
- Structured JSON data
- Variables from parent workflows
- User-provided values at runtime

### Output Handling

Flow results can include:
- Text responses
- Structured data (JSON)
- Generated artifacts
- Error messages and logs

---

## Important Limitations

### Read-Only Entities
- Installed flows are **read-only** in Codemie
- You cannot modify the flow logic from Codemie
- All changes must be made in AWS Bedrock console
- After AWS updates, the changes will be reflected automatically (the workflow uses the live AWS flow)

### Version Management
- Each installation is tied to a specific flow alias
- The alias in AWS determines which flow version is used
- If you update the alias routing in AWS, your Codemie workflow will use the updated version
- To use a different version, you can install a different alias

### Execution Limits
- Flow execution is subject to AWS service limits
- Long-running flows may timeout based on AWS configuration
- Check AWS CloudWatch for execution logs and errors

### Automatic Status Detection
- If a flow or alias is deleted in AWS, Codemie will detect this automatically
- The integration status will show errors for deleted resources
- You'll be notified when attempting to use a deleted flow

---

## Installation Status Messages

### Success
- **"Successfully installed [version name]"**: The workflow is ready to use
- The AI Run ID is displayed

### Errors

**"Connection Error"** (in integration table)
- The AWS credentials are invalid or expired
- Check your integration settings and update credentials

**"No flows found"**
- No flows exist in your AWS Bedrock account in this region
- Create flows in AWS Bedrock console first

**"No flows available"**
- You need to create flows in AWS Bedrock console
- Flows cannot be created directly in Codemie

**Installation Failed**
- The flow or alias may have been deleted in AWS during installation
- Refresh the page and verify the flow still exists in AWS
- Check that your credentials have the required permissions

---

## Flow Execution Monitoring

### Execution Status

Track flow executions in Codemie:

1. Go to **Workflows** → **Executions**
2. Filter by your installed AWS Flow
3. View execution status:
   - **Running**: Flow is currently executing
   - **Completed**: Flow finished successfully
   - **Failed**: Flow encountered an error
   - **Timeout**: Flow exceeded execution time limit

### Execution Logs

View detailed execution information:
- Input parameters
- Step-by-step progress
- Output results
- Error messages
- Execution duration

---

## Best Practices

1. **Use Meaningful Aliases**: Create descriptive alias names in AWS (e.g., "prod-v2", "dev-latest")

2. **Version Control**: Maintain multiple aliases for different environments
   - `dev` → Latest development version
   - `staging` → Pre-production testing
   - `prod` → Stable production version

3. **Test First**: Validate flows in AWS Bedrock console before installing

4. **Install Multiple Versions**: Install different aliases for development, testing, and production versions

5. **Input Validation**: Ensure your flows have proper input validation

6. **Error Handling**: Configure error handling nodes in your AWS Flow

7. **Document Flows**: Add descriptions in AWS for complex flow logic

8. **Monitor Performance**: Check execution times and optimize slow flows

9. **Clean Up Unused Installations**: Uninstall flow aliases you're no longer using to keep your workspace organized

10. **Keep Track of Versions**: Document which aliases are installed and their purposes

---

## Troubleshooting

### "Cannot find flow aliases"
- Verify the flow has at least one alias created in AWS
- Check that your AWS credentials have permission to list aliases (`bedrock:ListFlowAliases`)

### "More Info button not appearing"
- The flow status is "Not Prepared"
- Check the flow status in AWS Bedrock console
- Wait for AWS to complete flow validation

### "Install button disabled or missing"
- The alias may be in "Not Prepared" status
- The alias may point to a DRAFT version
- Check the alias configuration in AWS Bedrock console
- Ensure the version routing is properly configured

### "Flow execution failed"
- Check AWS CloudWatch logs for detailed error information
- Verify input parameters match the flow's expected schema
- Ensure all flow nodes are properly configured
- Check for AWS service limit issues

### "Timeout during execution"
- The flow may be too complex or slow
- Optimize flow nodes in AWS
- Consider splitting into smaller flows
- Check for infinite loops or excessive iterations

### "Workflow not responding"
- The flow alias may have been deleted or modified in AWS
- Check the flow status by viewing the AWS Integration page
- Check for "Connection Error" messages
- Verify the flow still exists in AWS Bedrock console

### "Cannot Open in Codemie"
- The workflow may have been deleted from Codemie
- Try uninstalling and reinstalling the alias

### "Invalid input parameters"
- Review the flow's input schema in AWS
- Ensure all required parameters are provided
- Verify parameter data types match the schema

### "Install failed with 404 error"
- The flow or alias may have been deleted between viewing and installing
- Refresh the page and try again

---

## Advanced Features

### Conditional Execution

AWS Flows support:
- Conditional branching based on data
- Iterators for processing lists
- Parallel execution of independent nodes

### Integration with Other AWS Services

Flows can integrate with:
- Lambda functions
- S3 buckets
- DynamoDB tables
- SQS queues
- External APIs

### Custom Variables

Use flow variables to:
- Store intermediate results
- Pass data between nodes
- Configure dynamic behavior

---

## Viewing Version Details

You can view detailed information about each alias version:

1. Click on an alias row to open the version details popup
2. View information including:
   - Version name
   - Description
   - Last updated date
   - Installation status

This helps you understand which version you're installing before you proceed.

---

## Next Steps

- Install AWS Agents as Assistants
- Install AWS Knowledge Bases as Data Sources
- Install AWS Guardrails
- Configure Guardrails
- Execute Workflows in Codemie
- Use Workflows in Parent Workflows
- Monitor Workflow Performance