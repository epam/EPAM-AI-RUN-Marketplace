# Installing AWS Guardrails

## Overview

AWS Bedrock Guardrails help you implement safety and content filtering for your AI applications. Install guardrails into Codemie to protect conversations and workflows from harmful, biased, or inappropriate content.

---

## Prerequisites

- AWS integration configured with valid credentials
- AWS Guardrail created in AWS Bedrock console
- Guardrail must be in "READY" status with at least one version

---

## Understanding Guardrail Status

### Guardrail Status
- **PREPARED**: The guardrail is ready to use (status is "READY" and version is numeric)
- **Not Prepared**: The guardrail is not ready (creating, failed, or version is DRAFT)

⚠️ **Important**: You can only view details and install guardrails with "PREPARED" status and numeric versions (e.g., "1", "2"). Guardrails with "Not Prepared" status will display an info badge but won't have a **More Info** button.

### Version Types
- **Numeric Versions** (1, 2, 3, etc.): Released versions that can be installed
- **DRAFT**: Work-in-progress version that cannot be installed

---

## Step-by-Step Installation Process

### Step 1: Navigate to AWS Guardrails

1. Go to **Settings** → **AWS Integration** in the left sidebar
2. Select **Guardrails**
3. You'll see a table listing all your AWS integrations

**Integration Table Shows:**
- **Setting Name**: Your integration name
- **Project**: Associated project
- **Entities**: List of available guardrails (up to 3 shown, with "..." if more exist)
- **Status**: Connection status or available entities

### Step 2: Select an Integration

1. Click on an integration row to view all available AWS guardrails for that integration
2. You'll see a list of all guardrails in your AWS account

**Guardrail List Shows:**
- Guardrail Name
- Guardrail Description
- Guardrail ID
- Status indicator (info badge for "Not Prepared", or **More Info** button for "PREPARED")

### Step 3: View Guardrail Details

1. Click **More Info** on a guardrail with "PREPARED" status
2. Review the guardrail information:
   - Guardrail configuration
   - Content filters (harmful content, hate speech, violence, sexual content)
   - Topic filters (denied topics)
   - Sensitive information filters
   - Available versions
   - Last modified date

### Step 4: Choose a Version

1. From the guardrail details view, you'll see all available versions for this guardrail
2. Review the version information:
   - Version number
   - Version description
   - Last updated date
   - Installation status

**Version Display:**
- Uninstalled versions show an **Install** button
- Installed versions show:
  - AI Run ID (the Codemie Guardrail ID)
  - **Assign** button to configure guardrail assignments
  - **Uninstall** button to remove the installation

⚠️ **Selection Rules:**
- Only numeric versions can be installed (1, 2, 3...)
- DRAFT versions are not available for installation
- Each version installs as a separate guardrail in Codemie
- You can install multiple versions of the same guardrail

### Step 5: Install the Version

1. Click **Install** on your selected version
2. The system will:
   - Create a new Guardrail in Codemie
   - Link it to your AWS Guardrail version
   - Enable it for assignment to entities
   - Display the AI Run ID once complete

3. After installation:
   - The **Install** button changes to show the AI Run ID
   - An **Assign** button appears to configure assignments
   - An **Uninstall** button appears to remove the installation

### Step 6: Assign the Guardrail

1. Click **Assign** on an installed version
2. Configure the guardrail assignment:
   - **Entity Type**: Choose Project, Assistant, Workflow, or Knowledge Base
   - **Entity**: Select the specific entity to protect
   - **Mode**: Select filter mode (All or Filtered)
   - **Source**: Choose where to apply (Input, Output, or Both)
3. Click **Assign** to apply the guardrail

---

## Guardrail Policies

### Content Filters

AWS Guardrails can filter:
- **Hate Speech**: Discriminatory or offensive content
- **Violence**: Violent or graphic content  
- **Sexual Content**: Inappropriate sexual material
- **Insults**: Personal attacks or offensive language
- **Misconduct**: Inappropriate behavior descriptions

Each filter has configurable strength levels: `NONE`, `LOW`, `MEDIUM`, `HIGH`

### Topic Filters

- **Denied Topics**: Blocks conversations about specific topics (e.g., politics, religion, medical advice)

### Sensitive Information Filters

Automatically detects and blocks:
- Email addresses
- Phone numbers
- Credit card numbers
- Social Security numbers
- AWS credentials
- IP addresses
- Vehicle identification numbers
- License plates
- Custom regex patterns

---

## Managing Installed Guardrails

### Viewing Installed Guardrails

From the guardrail details view, installed versions are marked with:
- The AI Run ID displayed prominently
- Last updated date
- **Assign** button to manage assignments
- **Uninstall** button to remove the installation

### Assigning Guardrails

1. Click **Assign** on an installed version
2. The Assignment popup allows you to:
   - Select entity type (Project, Assistant, Workflow, Knowledge Base)
   - Choose specific entity to protect
   - Configure mode (All or Filtered)
   - Set source (Input, Output, or Both)
3. Click **Assign** to save

**Guardrail Modes:**
- **All**: Returns full analysis including allowed and blocked content
- **Filtered**: Returns only blocked content and reasons

**Guardrail Sources:**
- **Input**: Applies to user input only
- **Output**: Applies to assistant/workflow output only
- **Both**: Applies to both input and output

### Uninstalling a Version

1. From the guardrail details view, click **Uninstall** on an installed version
2. Confirm the uninstallation in the popup:
   - Review the version information
   - Read the warning about deletion
   - Click **Uninstall** to confirm or **Cancel** to abort

⚠️ **Warning**: Uninstalling will permanently delete the guardrail from Codemie. Any assignments to assistants, workflows, or knowledge bases will be removed.

### Reinstalling a Version

If you uninstall a version, you can reinstall it at any time:
1. The **Install** button will reappear
2. Click **Install** to create a new guardrail (with a new AI Run ID)
3. Note: Previous assignments are not restored; you'll need to reconfigure them

---

## Using Installed Guardrails

Guardrails can be applied to:

1. **Projects**: Apply default guardrails to all entities in a project
2. **Assistants**: Filter all conversations with specific assistants
3. **Workflows**: Protect workflow inputs and outputs
4. **Knowledge Bases**: Filter retrieved content

### Assignment Priority

When multiple guardrails are assigned:
- Entity-specific assignments override project-level assignments
- You can view both global (project/other entity) and entity-specific assignments
- Entity assignments are editable from the entity detail pages

---

## Important Limitations

### Read-Only Entities
- Installed guardrails are **read-only** in Codemie
- You cannot modify guardrail policies from Codemie
- All policy changes must be made in AWS Bedrock console
- After AWS updates, the changes will be reflected automatically (the guardrail uses the live AWS configuration)

### Version Management
- Each installation is tied to a specific guardrail version
- If you create a new version in AWS, you can install it separately
- You can have multiple versions installed simultaneously
- Assign different versions to different entities as needed

### Automatic Status Detection
- If a guardrail or version is deleted in AWS, Codemie will detect this automatically
- The integration status will show errors for deleted resources
- You'll be notified when attempting to use a deleted guardrail

---

## Installation Status Messages

### Success
- **"Successfully installed [version]"**: The guardrail is ready to assign
- The AI Run ID is displayed

### Errors

**"Connection Error"** (in integration table)
- The AWS credentials are invalid or expired
- Check your integration settings and update credentials

**"No guardrails found"**
- No guardrails exist in your AWS Bedrock account in this region
- Create guardrails in AWS Bedrock console first

**"No guardrails available"**
- You need to create guardrails in AWS Bedrock console
- Guardrails cannot be created directly in Codemie

**Installation Failed**
- The guardrail or version may have been deleted in AWS during installation
- Refresh the page and verify the guardrail still exists in AWS
- Check that your credentials have the required permissions

---

## Best Practices

1. **Version Strategy**: Use version numbers to track policy changes
   - v1 = Initial policy
   - v2 = Added topic filters
   - v3 = Strengthened content filters

2. **Test Before Deployment**: Always test guardrails with representative content before assigning to production entities

3. **Layer Protections**: Combine multiple filter types for comprehensive protection

4. **Balance Safety and Usability**: Avoid overly restrictive policies that hinder legitimate use

5. **Regular Review**: Periodically review guardrail effectiveness and adjust policies in AWS

6. **Document Policies**: Keep notes on what each version filters and why

7. **Gradual Rollout**: Test new guardrail versions with a subset of entities before project-wide deployment

8. **Clean Up Unused Installations**: Uninstall guardrail versions you're no longer using to keep your workspace organized

---

## Troubleshooting

### "Cannot find guardrails"
- Verify you have guardrails created in your AWS account
- Check that your AWS credentials have permission to list guardrails (`bedrock:ListGuardrails`)

### "More Info button not appearing"
- The guardrail status is "Not Prepared"
- Check the guardrail status in AWS Bedrock console
- Ensure the guardrail is in "READY" state

### "Install button disabled or missing"
- The version may be in DRAFT status
- Only numeric versions can be installed
- Publish a version in AWS Bedrock console first

### "Guardrail blocking too much content"
- Review filter strength levels in AWS (consider reducing from HIGH to MEDIUM)
- Check topic filters for overly broad restrictions
- Review sensitive information filters for false positives
- Test with legitimate content examples

### "Guardrail not catching violations"
- Increase filter strength levels in AWS Bedrock console
- Add specific denied topics
- Review sensitive information patterns
- Create a new version with updated policies

### "Cannot assign guardrail"
- Verify the guardrail is still available in AWS
- Check your AWS credentials haven't expired
- Ensure the guardrail version hasn't been deleted
- Refresh the page and try again

### "Assignment not working"
- Check that the guardrail version is installed
- Verify the entity (assistant, workflow, knowledge base) still exists
- Ensure you have permission to modify the entity

---

## Viewing Version Details

You can view detailed information about each guardrail version:

1. Click on a version row to open the version details popup
2. View information including:
   - Version number
   - Description
   - Topics configured (denied topics)
   - Content filters configured
   - Last updated date
   - Installation status

This helps you understand the guardrail configuration before you proceed with installation.

---

## Next Steps

- Install AWS Agents as Assistants
- Install AWS Knowledge Bases as Data Sources
- Install AWS Flows as Workflows
- Configure Guardrail Assignments