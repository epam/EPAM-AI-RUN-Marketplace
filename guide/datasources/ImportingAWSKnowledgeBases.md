# Installing AWS Knowledge Bases as Data Sources

## Overview

AWS Bedrock Knowledge Bases allow you to connect your data sources for retrieval-augmented generation (RAG). Install them into Codemie to make your organization's knowledge available to assistants and workflows.

---

## Prerequisites

- AWS integration configured with valid credentials
- AWS Knowledge Base created and synchronized in AWS Bedrock console
- Knowledge Base must be in "ACTIVE" status

---

## Understanding Knowledge Base Status

### Status Types
- **PREPARED**: The knowledge base is fully synchronized and ready to use
- **Not Prepared**: The knowledge base is not ready (creating, updating, failed, or deleting)

⚠️ **Important**: You can only view details and install knowledge bases with "PREPARED" status. Knowledge bases with "Not Prepared" status will display an info badge but won't have a **More Info** button.

### Synchronization
- Knowledge bases must complete their initial data synchronization before installation
- Check the AWS Bedrock console to verify synchronization status
- Large knowledge bases may take time to index all documents

---

## Step-by-Step Installation Process

### Step 1: Navigate to AWS Knowledge Bases

1. Go to **Settings** → **AWS Integration** in the left sidebar
2. Select **Knowledge Bases**
3. You'll see a table listing all your AWS integrations

**Integration Table Shows:**
- **Setting Name**: Your integration name
- **Project**: Associated project
- **Entities**: List of available knowledge bases (up to 3 shown, with "..." if more exist)
- **Status**: Connection status or available entities

### Step 2: Select an Integration

1. Click on an integration row to view all available AWS knowledge bases for that integration
2. You'll see a list of all knowledge bases in your AWS account

**Knowledge Base List Shows:**
- Knowledge Base Name
- Knowledge Base Description
- Knowledge Base ID
- Status indicator (info badge for "Not Prepared", or **More Info** button for "PREPARED")

### Step 3: View Knowledge Base Details

1. Click **More Info** on a knowledge base with "PREPARED" status
2. Review the information:
   - Knowledge base configuration
   - Data source details
   - Storage configuration (vector database)
   - Last modified date

### Step 4: Install the Knowledge Base

1. From the knowledge base details view, click the **Install** button
2. The system will:
   - Create a new Data Source in Codemie
   - Link it to your AWS Knowledge Base
   - Configure retrieval settings
   - Display the AI Run ID once complete

3. After installation:
   - The **Install** button changes to show the AI Run ID
   - An **Open in Codemie** button appears to navigate directly to the data source
   - An **Uninstall** button appears to remove the installation

### Step 5: Access Your Data Source

1. Click **Open in Codemie** to view your newly installed data source
2. Or navigate to the **Data Sources** page to find it in your data sources list

---

## Managing Installed Knowledge Bases

### Viewing Installed Knowledge Bases

From the knowledge base details view, installed knowledge bases display:
- The AI Run ID displayed prominently
- Last updated date
- **Open in Codemie** button
- **Uninstall** button

### Uninstalling a Knowledge Base

1. From the knowledge base details view, click **Uninstall**
2. Confirm the uninstallation in the popup:
   - Review the knowledge base information
   - Read the warning about deletion
   - Click **Uninstall** to confirm or **Cancel** to abort

⚠️ **Warning**: Uninstalling will permanently delete the data source from Codemie. Any assistants or workflows using this data source will no longer have access to it.

### Reinstalling a Knowledge Base

If you uninstall a knowledge base, you can reinstall it at any time:
1. The **Install** button will reappear
2. Click **Install** to create a new data source (with a new AI Run ID)
3. Note: This creates a completely new data source; previous configurations are not restored

---

## Using Installed Knowledge Bases

### With Assistants

1. Edit or create an assistant
2. Go to the **Data Sources** section
3. Select your installed AWS Knowledge Base
4. The assistant will now have access to query your knowledge base

### In Workflows

1. Add a knowledge base retrieval node
2. Select your installed AWS Knowledge Base
3. Configure the query and retrieval parameters
4. The workflow will retrieve relevant information during execution

### Query Behavior

- Queries are sent to AWS Bedrock Knowledge Base API
- AWS performs vector similarity search on your indexed documents
- Results are ranked by relevance
- You can configure the number of results returned (default: 5)

---

## Important Limitations

### Read-Only Entities
- Installed knowledge bases are **read-only** in Codemie
- You cannot modify the knowledge base configuration from Codemie
- Data source updates must be done in AWS Bedrock console
- After updating data in AWS, the knowledge base automatically reflects changes

### Data Synchronization
- New documents added to your data source will be indexed by AWS automatically
- Allow time for AWS to synchronize and index new content
- Check synchronization status in AWS Bedrock console

### Automatic Status Detection
- If a knowledge base is deleted in AWS, Codemie will detect this automatically
- The integration status will show errors for deleted resources
- You'll be notified when attempting to use a deleted knowledge base

---

## Installation Status Messages

### Success
- **"Successfully installed [knowledge base name]"**: The data source is ready to use
- The AI Run ID is displayed

### Errors

**"Connection Error"** (in integration table)
- The AWS credentials are invalid or expired
- Check your integration settings and update credentials

**"No knowledge bases found"**
- No knowledge bases exist in your AWS Bedrock account in this region
- Create knowledge bases in AWS Bedrock console first

**"No knowledge bases available"**
- You need to create knowledge bases in AWS Bedrock console
- Knowledge bases cannot be created directly in Codemie

**Installation Failed**
- The knowledge base may have been deleted in AWS during installation
- Refresh the page and verify the knowledge base still exists in AWS
- Check that your credentials have the required permissions

---

## Best Practices

1. **Complete Indexing First**: Ensure your knowledge base has completed its initial indexing before installation

2. **Monitor Synchronization**: Regularly check that new documents are being indexed in AWS

3. **Test Queries**: Test retrieval queries in AWS Bedrock console before installing

4. **Optimize Chunking**: Configure appropriate chunking strategies in AWS for your content type

5. **Document Coverage**: Ensure your knowledge base covers the topics your assistants need

6. **Regular Updates**: Keep your data sources up to date in AWS

7. **Access Control**: Configure appropriate IAM permissions for knowledge base access

8. **Clean Up Unused Installations**: Uninstall knowledge bases you're no longer using to keep your workspace organized

---

## Retrieval Configuration

### Query Parameters

You can configure how your assistant queries the knowledge base:

- **Number of Results**: How many documents to retrieve (1-100)
- **Minimum Score**: Relevance threshold for returned results
- **Metadata Filters**: Filter results by metadata attributes

### Optimizing Retrieval

- Use specific queries for better results
- Include relevant keywords
- Provide context in your queries
- Use metadata filters to narrow results

---

## Troubleshooting

### "Cannot find knowledge bases"
- Verify you have knowledge bases created in your AWS account
- Check that your AWS credentials have permission to list knowledge bases (`bedrock-agent:ListKnowledgeBases`)

### "More Info button not appearing"
- The knowledge base status is "Not Prepared"
- Check the knowledge base status in AWS Bedrock console
- Wait for AWS to complete knowledge base indexing

### "Install button disabled or missing"
- The knowledge base may be in "Not Prepared" status
- Check the knowledge base configuration in AWS Bedrock console
- Ensure the knowledge base has completed synchronization

### "No results returned"
- Check that your knowledge base has indexed documents
- Verify the query is relevant to your indexed content
- Review metadata filters if applied
- Check synchronization status in AWS

### "Knowledge base unavailable"
- The knowledge base may have been deleted in AWS
- Check the status by viewing the AWS Integration page
- Check for "Connection Error" messages
- Verify the knowledge base still exists in AWS Bedrock console

### "Cannot Open in Codemie"
- The data source may have been deleted from Codemie
- Try uninstalling and reinstalling the knowledge base

### "Slow query performance"
- Large knowledge bases may take longer to query
- Consider using metadata filters to narrow the search
- Check AWS CloudWatch for query performance metrics

### "Install failed with 404 error"
- The knowledge base may have been deleted between viewing and installing
- Refresh the page and try again

---

## Advanced Features

### Metadata Filtering

Use metadata to filter knowledge base results:

```json
{
  "metadataFilter": {
    "equals": {
      "key": "department",
      "value": "engineering"
    }
  }
}
```

### Hybrid Search

AWS Knowledge Bases support both:
- **Semantic Search**: Vector similarity for conceptual matches
- **Keyword Search**: Traditional text matching

Both are automatically combined for optimal results.

---

## Viewing Knowledge Base Details

You can view detailed information about each knowledge base:

1. Click **More Info** on a knowledge base row to open the details view
2. View information including:
   - Knowledge base name
   - Description
   - Last updated date
   - Installation status
   - **Install** button (if not installed)
   - **Open in Codemie** and **Uninstall** buttons (if installed)

This helps you understand the knowledge base configuration before you proceed with installation.

---

## Next Steps

- Install AWS Agents as Assistants
- Install AWS Guardrails
- Install AWS Flows as Workflows
- Configure Guardrails