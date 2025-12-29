# Installing AWS Agents as Assistants

## Overview

AWS Bedrock Agents can be installed into Codemie as Assistants. This allows you to use your configured AWS Agents directly in conversations and workflows.

---

## Prerequisites

- AWS integration configured with valid credentials
- AWS Agent created and prepared in AWS Bedrock console
- Agent must have at least one Agent Alias in "PREPARED" status

---

## Understanding Agent Status

### Agent Status
- **PREPARED**: The agent is ready to be installed and used
- **Not Prepared**: The agent is not ready (still being created, failed, or deleted)

⚠️ **Important**: You can only view details and install agents with "PREPARED" status. Agents with "Not Prepared" status will display an info badge but won't have a **More Info** button.

### Agent Alias Status
- **PREPARED**: The alias is ready to be installed
- **Not Prepared**: The alias cannot be installed (routing configuration incomplete or version not ready)

ℹ️ **Note**: Each agent can have multiple aliases representing different versions or configurations.

---

## Step-by-Step Installation Process

### Step 1: Navigate to AWS Agents

1. Go to **Settings** → **AWS Integration** in the left sidebar
2. Select **Agents**
3. You'll see a table listing all your AWS integrations

**Integration Table Shows:**
- **Setting Name**: Your integration name
- **Project**: Associated project
- **Entities**: List of available agents (up to 3 shown, with "..." if more exist)
- **Status**: Connection status or available entities

### Step 2: Select an Integration

1. Click on an integration row to view all available AWS agents for that integration
2. You'll see a list of all agents in your AWS account

**Agent List Shows:**
- Agent Name
- Agent Description
- Agent ID
- Status indicator (info badge for "Not Prepared", or **More Info** button for "PREPARED")

### Step 3: View Agent Details

1. Click **More Info** on an agent with "PREPARED" status
2. Review the agent information:
   - Agent configuration
   - Available aliases/versions
   - Instructions and capabilities
   - Last modified date

### Step 4: Choose an Alias

1. From the agent details view, you'll see all available aliases for this agent
2. Review the alias information:
   - Alias Name
   - Alias ID
   - Description
   - Last updated date
   - Installation status

**Alias Display:**
- Uninstalled aliases show an **Install** button
- Installed aliases show:
  - AI Run ID (the Codemie Assistant ID)
  - **Open in Codemie** button to navigate to the assistant
  - **Uninstall** button to remove the installation

⚠️ **Selection Rules:**
- You can only install aliases with "PREPARED" status
- Each alias installs as a separate assistant in Codemie
- You can install multiple versions/aliases of the same agent

### Step 5: Install the Alias

1. Click **Install** on your selected alias
2. The system will:
   - Create a new Assistant in Codemie
   - Link it to your AWS Agent Alias
   - Set up the necessary configuration
   - Display the AI Run ID once complete

3. After installation:
   - The **Install** button changes to show the AI Run ID
   - An **Open in Codemie** button appears to navigate directly to the assistant
   - An **Uninstall** button appears to remove the installation

### Step 6: Access Your Assistant

1. Click **Open in Codemie** to view your newly installed assistant
2. Or navigate to the **Assistants** page to find it in your assistants list

---

## Managing Installed Agents

### Viewing Installed Agents

From the agent details view, installed aliases are marked with:
- The AI Run ID displayed prominently
- Last updated date
- **Open in Codemie** button
- **Uninstall** button

### Uninstalling an Alias

1. From the agent details view, click **Uninstall** on an installed alias
2. Confirm the uninstallation in the popup:
   - Review the version information
   - Read the warning about deletion
   - Click **Uninstall** to confirm or **Cancel** to abort

⚠️ **Warning**: Uninstalling will permanently delete the assistant from Codemie. Any conversations or workflows using this assistant will no longer work.

### Reinstalling an Alias

If you uninstall an alias, you can reinstall it at any time:
1. The **Install** button will reappear
2. Click **Install** to create a new assistant (with a new AI Run ID)
3. Note: This creates a completely new assistant; previous conversations are not restored

---

## Using Installed Agents

### In Conversations
1. Start a new conversation or open an existing one
2. Select your installed AWS Agent assistant from the assistant picker
3. The assistant will use the AWS Agent to process your messages

### In Workflows
1. Add an assistant node to your workflow
2. Select your installed AWS Agent assistant
3. The workflow will invoke the AWS Agent when reaching this node

---

## Important Limitations

### Read-Only Entities
- Installed agents are **read-only** in Codemie
- You cannot modify the agent configuration from Codemie
- All changes must be made in the AWS Bedrock console
- After AWS updates, the changes will be reflected automatically (the assistant uses the live AWS agent)

### Version Management
- Each installation is tied to a specific agent alias
- The alias in AWS determines which agent version is used
- If you update the alias routing in AWS, your Codemie assistant will use the updated version
- To use a different version, you can install a different alias

### Automatic Status Detection
- If an agent or alias is deleted in AWS, Codemie will detect this automatically
- The integration status will show errors for deleted resources
- You'll be notified when attempting to use a deleted agent

---

## Installation Status Messages

### Success
- **"Successfully installed [version name]"**: The assistant is ready to use
- The AI Run ID is displayed

### Errors

**"Connection Error"** (in integration table)
- The AWS credentials are invalid or expired
- Check your integration settings and update credentials

**"No agents found"**
- No agents exist in your AWS Bedrock account in this region
- Create agents in AWS Bedrock console first

**"No agents available"**
- You need to create agents in AWS Bedrock console
- Agents cannot be created directly in Codemie

**Installation Failed**
- The agent or alias may have been deleted in AWS during installation
- Refresh the page and verify the agent still exists in AWS
- Check that your credentials have the required permissions

---

## Best Practices

1. **Use Descriptive Aliases**: Create meaningful alias names in AWS to identify them easily in Codemie

2. **Test Before Installing**: Ensure your agent works correctly in AWS before installing

3. **Install Multiple Versions**: Install different aliases for development, testing, and production versions

4. **Monitor Status**: Regularly check the AWS Integration page for connection errors or status issues

5. **Clean Up Unused Installations**: Uninstall aliases you're no longer using to keep your workspace organized

6. **Document Your Versions**: Keep track of which aliases are installed and their purposes

---

## Troubleshooting

### "Cannot find agent aliases"
- Verify the agent has at least one alias created in AWS
- Check that your AWS credentials have permission to list aliases (`bedrock-agent:ListAgentAliases`)

### "More Info button not appearing"
- The agent status is "Not Prepared"
- Check the agent status in AWS Bedrock console
- Wait for AWS to complete agent preparation

### "Install button disabled or missing"
- The alias may be in "Not Prepared" status
- Check the alias configuration in AWS Bedrock console
- Ensure the version routing is properly configured

### "Assistant not responding"
- The agent alias may have been deleted or modified in AWS
- Check the agent status by viewing the AWS Integration page
- Check for "Connection Error" messages
- Verify the agent still exists in AWS Bedrock console

### "Cannot Open in Codemie"
- The assistant may have been deleted from Codemie
- Try uninstalling and reinstalling the alias

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

- Install AWS Knowledge Bases as Data Sources
- Install AWS Guardrails
- Install AWS Flows as Workflows
- Configure Guardrails