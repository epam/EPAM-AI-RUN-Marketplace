# AWS Bedrock Integration Guide

## Overview

AWS Bedrock integration allows you to install and use AWS AI services directly in Codemie, including AI Agents, Knowledge Bases, Guardrails, and Flows.

---

## Setting Up AWS Integration

### Step 1: Create AWS Integration

To enable AWS Bedrock functionality, you need to create an AWS integration in Codemie:

1. Navigate to **Integrations** page
2. Click **Create** → **Create Project Integration**
3. Select **AWS** as the credential type
4. Provide the following credentials:

#### Option A: Temporary Credentials (Recommended for Testing)
- **AWS Access Key**: Your temporary access key
- **AWS Secret Key**: Your temporary secret key
- **AWS Session Token**: Your session token (if using temporary credentials)
- **AWS Region**: The region where your Bedrock resources are located (e.g., `us-east-1`)

#### Option B: Permanent Credentials
- **AWS Access Key**: Your IAM user access key
- **AWS Secret Key**: Your IAM user secret key
- **AWS Region**: The region where your Bedrock resources are located

### Step 2: Required AWS Permissions

Your AWS credentials must have the following permissions:

**For Agents:**
- `bedrock-agent:GetAgent`
- `bedrock-agent:ListAgents`
- `bedrock-agent:GetAgentAlias`
- `bedrock-agent:ListAgentAliases`
- `bedrock-agent:InvokeAgent`

**For Knowledge Bases:**
- `bedrock-agent:GetKnowledgeBase`
- `bedrock-agent:ListKnowledgeBases`
- `bedrock-agent:Retrieve`

**For Guardrails:**
- `bedrock:GetGuardrail`
- `bedrock:ListGuardrails`
- `bedrock-runtime:ApplyGuardrail`

**For Flows:**
- `bedrock:GetFlow`
- `bedrock:ListFlows`
- `bedrock:GetFlowAlias`
- `bedrock:ListFlowAliases`
- `bedrock:InvokeFlow`

### Step 3: Verify Integration

Once you create the integration:

1. Go to **Settings** → **AWS Integration** in the left sidebar
2. You'll see management pages for each entity type:
   - **Agents** (AWS Bedrock Agents)
   - **Flows** (AWS Bedrock Prompt Flows)
   - **Knowledge Bases** (AWS Bedrock Knowledge Bases)
   - **Guardrails** (AWS Bedrock Guardrails)

3. Each management page shows a table with:
   - **Setting Name**: Your integration name
   - **Project**: Associated project
   - **Entities**: List of available AWS resources that can be installed (displays up to 3 entities with "..." if more exist)
   - **Status**: 
     - Valid integrations show available entities
     - "Connection Error" for invalid configurations
     - "No [entities] found" if the integration is valid but no resources exist in AWS
     - "No [entities] available" with a hint that resources must be created in AWS Bedrock

---

## Navigation Flow

After setup, you can browse and install AWS Bedrock resources:

1. **Settings Overview**: Go to **Settings** → **AWS Integration** and select the entity type (Agents, Flows, Knowledge Bases, or Guardrails)

2. **Integration Selection**: Click on an integration row to view all available AWS resources for that integration

3. **Entity List**: Browse available entities with:
   - Entity name and description
   - Entity ID
   - Status indicator (Not Prepared, or ready to install)
   - **More Info** button for entities with "PREPARED" status

4. **Entity Details**: Click **More Info** to view:
   - Detailed information about the entity
   - Available versions/aliases
   - **Install** button for each version

5. **Installation**: Click **Install** to make the AWS resource available in Codemie. For agents, this creates a new assistant; for knowledge bases, a new data source; for flows, a new workflow; for guardrails, they become available for assignment.

---

## Entity Status and Actions

### Entity Statuses

- **Not Prepared**: The resource exists in AWS but is not ready for installation (shows info badge)
- **PREPARED**: The resource is ready to be installed (shows "More Info" button)
- **Installed**: The resource has been installed and shows:
  - **Open in Codemie** button to navigate to the installed resource
  - **Uninstall** button to remove the installation

### Installation Process

When you install an AWS Bedrock resource:

- **Agents**: Creates a new assistant in your Assistants page
- **Knowledge Bases**: Creates a new data source in your Data Sources page
- **Flows**: Creates a new workflow in your Workflows page
- **Guardrails**: Makes the guardrail available for assignment to projects, assistants, workflows, or knowledge bases

### Version Management

For Agents and Flows, you can:
- View all available versions/aliases
- Install multiple versions simultaneously
- See which versions are currently installed (shows AI Run ID)
- View version details including description and last modified date
- Uninstall specific versions when no longer needed

For Guardrails:
- View all available versions
- Install multiple versions
- Assign installed versions to entities (assistants, workflows, knowledge bases, or projects)
- Configure guardrail mode (All or Filtered) and source (Input, Output, or Both)
- View version details including topics and content filters

---

## Troubleshooting

### "Connection Error"
- Verify your AWS credentials are correct in the integration settings
- Check that your credentials haven't expired (for temporary credentials)
- Ensure your IAM user/role has the required permissions
- Confirm the AWS region is correct

### "No [entities] found"
This message appears when:
- The AWS integration is working correctly
- You have valid credentials with proper permissions
- But no resources of this type exist in your AWS Bedrock environment

**Resolution**: Create the resources in AWS Bedrock first, then refresh the page.

### "No [entities] available"
This message indicates:
- Resources for this entity type can only be created in AWS Bedrock
- They cannot be created directly in Codemie

**Resolution**: Go to AWS Bedrock console to create the resources.

### "Not Prepared" Status
- The resource exists in AWS but is not in a ready state
- Check the resource status in AWS Bedrock console
- Ensure the resource has completed its setup/preparation process

### Installation Fails
- The resource may have been deleted in AWS
- The resource may have been moved to a different region
- Your credentials may no longer have access to the resource
- Try refreshing the entity list and verify the resource still exists in AWS

### Cannot See Installed Resources in Codemie
After installation:
- **Agents** → Go to Assistants page
- **Knowledge Bases** → Go to Data Sources page
- **Flows** → Go to Workflows page
- **Guardrails** → Access through guardrail assignment in entity settings

---

## Next Steps

- Install AWS Agents as Assistants
- Install AWS Knowledge Bases as Data Sources
- Install AWS Guardrails
- Install AWS Flows as Workflows
- Configure Guardrails