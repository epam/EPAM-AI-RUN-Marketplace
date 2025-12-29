# Importing AWS AgentCore Runtimes

## Overview

AWS Bedrock AgentCore Runtimes provide a new way to deploy and execute AI agents with enhanced capabilities and performance. Import AgentCore Runtime Endpoints into Codemie to use them as assistants in conversations and workflows.

---

## Prerequisites

- AWS integration configured with valid credentials
- AWS AgentCore Runtime created in AWS Bedrock console
- Runtime must be in "READY" status with at least one endpoint

---

## Understanding AgentCore Runtime Status

### Runtime Status
- **PREPARED**: The runtime is deployed and ready to use (status is "READY")
- **NOT_PREPARED**: The runtime is not ready (creating, updating, failed, or deleted)

### Endpoint Status
- **PREPARED**: The endpoint is active and can process requests (status is "READY")
- **NOT_PREPARED**: The endpoint is not ready (provisioning, updating, or failed)

⚠️ **Important**: You can only import endpoints with "PREPARED" status.

---

## AgentCore vs. Traditional Agents

### Key Differences

**AgentCore Runtimes**:
- More flexible invocation patterns
- Custom payload structure support
- Enhanced streaming capabilities
- Better integration with custom tooling

**Traditional Agents**:
- Standard AWS Agent builder interface
- Fixed invocation pattern
- Managed through Agent console

**When to Use AgentCore**:
- Need custom invocation payload structure
- Require specialized agent architectures
- Want fine-grained control over agent behavior
- Building custom agent frameworks

---

## Step-by-Step Import Process

### Step 1: Browse Available Runtimes

1. Navigate to **Vendors** → **AWS** → **AgentCore Runtimes**
2. Select your AWS integration from the settings dropdown
3. You'll see a list of all AgentCore runtimes in your AWS account

**Runtime List Shows:**
- Runtime ID
- Runtime Name
- Status (PREPARED/NOT_PREPARED)
- Description
- Version
- Last Updated Date

### Step 2: Select a Runtime

1. Click on a runtime to view its details
2. Review the runtime information:
   - Configuration details
   - Available endpoints
   - Deployment status

### Step 3: Choose an Endpoint

1. From the runtime details page, click **View Endpoints**
2. You'll see all endpoints for this runtime
3. Select the endpoint you want to import

**Endpoint Information:**
- Endpoint ID
- Endpoint Name
- Status (PREPARED/NOT_PREPARED)
- Live Version
- Target Version
- ARN
- Description
- Created/Updated dates

⚠️ **Selection Rules:**
- Only endpoints with "READY" status can be imported
- Each endpoint imports as a separate assistant in Codemie

### Step 4: Configure Invocation Payload

**Important**: AgentCore endpoints require a custom invocation payload structure.

1. Click **Import** on your selected endpoint
2. Configure the **Invocation JSON Template**:

```json
{
  "message": "__QUERY_PLACEHOLDER__",
  "sessionId": "optional-session-id",
  "additionalParameters": {
    "key": "value"
  }
}
```

**Key Points**:
- Must include `__QUERY_PLACEHOLDER__` where the user's query will be inserted
- Use valid JSON structure
- Can include custom fields required by your runtime
- Session management is optional

**Example Templates**:

**Simple Message**:
```json
{
  "message": "__QUERY_PLACEHOLDER__"
}
```

**With Context**:
```json
{
  "prompt": "__QUERY_PLACEHOLDER__",
  "context": {
    "userId": "user123",
    "conversationId": "conv456"
  }
}
```

**With Parameters**:
```json
{
  "query": "__QUERY_PLACEHOLDER__",
  "parameters": {
    "temperature": 0.7,
    "maxTokens": 1000
  }
}
```

3. Click **Validate** to check your JSON structure
4. Click **Import** to complete the process

### Step 5: Confirmation

The system will:
- Validate your invocation JSON
- Create a new Assistant in Codemie
- Link it to your AgentCore Runtime Endpoint
- Configure the invocation settings

You'll see a success message with the Assistant ID.

---

## Using Imported AgentCore Runtimes

### In Conversations

1. Start a new conversation
2. Select your imported AgentCore Runtime assistant
3. Send messages - they'll be formatted using your invocation template
4. The runtime processes the request and returns responses

### In Workflows

1. Add an assistant node to your workflow
2. Select your imported AgentCore Runtime assistant
3. Configure input mapping
4. The workflow invokes the runtime when reaching this node

### Response Handling

AgentCore Runtimes can return:
- **Streaming Responses**: Real-time text generation (event-stream format)
- **JSON Responses**: Structured data responses
- **Mixed Content**: Text, data, and metadata

---

## Invocation JSON Template Guide

### Required Elements

**Placeholder**: `__QUERY_PLACEHOLDER__`
- Must appear exactly as shown (case-sensitive)
- Can be anywhere in your JSON structure
- Will be replaced with the actual user query at runtime

### Template Validation

The system checks:
1. Valid JSON syntax
2. Presence of `__QUERY_PLACEHOLDER__`
3. Placeholder used as a string value (not as a key)

**Valid**:
```json
{
  "input": "__QUERY_PLACEHOLDER__"
}
```

**Invalid**:
```json
{
  "__QUERY_PLACEHOLDER__": "value"
}
```

### Complex Templates

You can nest the placeholder deeply:

```json
{
  "agent": {
    "input": {
      "conversation": {
        "messages": [
          {
            "role": "user",
            "content": "__QUERY_PLACEHOLDER__"
          }
        ]
      }
    }
  }
}
```

### Dynamic Values

**Auto-Generated**:
- `sessionId`: Automatically added if not present
- Conversation context: Managed by Codemie

**Custom Values**: Must be hardcoded in the template
```json
{
  "message": "__QUERY_PLACEHOLDER__",
  "userId": "fixed-user-id",
  "appVersion": "1.0"
}
```

---

## Important Limitations

### Read-Only Entities
- Imported AgentCore Runtimes are **read-only** in Codemie
- You cannot modify runtime configuration from Codemie
- All changes must be made in AWS Bedrock console
- Invocation template can be updated in Codemie after import

### Invocation Template Updates

To update the invocation template:
1. Go to **Assistants** → Select your AgentCore Runtime assistant
2. Click **Edit** → Navigate to **AgentCore Settings**
3. Modify the **Invocation JSON Template**
4. Click **Validate** then **Save**

### Automatic Cleanup
- If an endpoint is deleted in AWS, Codemie will detect this
- The assistant will be marked as unavailable
- You'll be notified when attempting to use a deleted endpoint

---

## Import Status Messages

### Success
- **"Endpoint imported successfully"**: The assistant is ready to use
- **"aiRunId"**: Shows the Codemie Assistant ID

### Errors

**"Invalid invocation JSON"**
- Your JSON template has syntax errors
- Missing `__QUERY_PLACEHOLDER__`
- Placeholder used incorrectly

**"Endpoint not found"**
- The endpoint was deleted in AWS
- Check the endpoint name and try again

**"Endpoint not in READY status"**
- The endpoint is still provisioning
- Wait for AWS to finish deploying the endpoint
- Check the status in AWS Bedrock console

**"Runtime not found"**
- The parent runtime was deleted
- Verify the runtime exists in AWS

---

## Response Format Handling

### Streaming Responses (text/event-stream)

AgentCore can stream responses in real-time:

**Format**:
```
data: {"response": "First part"}
data: {"response": "Second part"}
data: {"response": "Final part"}
```

**Handling**: Codemie automatically concatenates streaming chunks

### JSON Responses (application/json)

Structured responses:

```json
{
  "response": "The answer is...",
  "metadata": {
    "confidence": 0.95,
    "sources": ["doc1", "doc2"]
  }
}
```

**Handling**: Codemie extracts the `response` field or returns full JSON

---

## Best Practices

1. **Test Your Invocation Template**: Validate in AWS before importing
   - Test with various input lengths
   - Verify all required fields are present
   - Check response format

2. **Document Your Template**: Add comments in your project documentation
   ```json
   // This template requires:
   // - message: user input (auto-filled)
   // - sessionId: conversation tracking (auto-generated)
   {
     "message": "__QUERY_PLACEHOLDER__",
     "sessionId": "auto"
   }
   ```

3. **Keep Templates Simple**: Minimize complexity
   - Use only required fields
   - Avoid deeply nested structures unless necessary
   - Make it easy to update

4. **Version Your Templates**: Track template changes
   - Note why changes were made
   - Keep old versions for rollback
   - Test changes before updating production assistants

5. **Error Handling**: Ensure your runtime handles errors gracefully
   - Invalid inputs
   - Missing fields
   - Timeout scenarios

6. **Monitor Performance**: Check execution times
   - AgentCore endpoints should respond quickly
   - Long delays may indicate runtime issues
   - Review AWS CloudWatch logs

7. **Security**: Don't hardcode sensitive data in templates
   - No API keys
   - No passwords
   - No PII

---

## Troubleshooting

### "Invocation failed with 400 error"
- Check your invocation JSON template
- Verify all required fields are present
- Review AWS CloudWatch logs for the runtime
- Test the template directly in AWS console

### "Response timeout"
- The runtime is taking too long to respond
- Check runtime performance in AWS
- Consider optimizing the runtime code
- Verify network connectivity

### "Invalid response format"
- The runtime returned unexpected format
- Check response parsing in AWS CloudWatch
- Verify content-type headers
- Update runtime to return expected format

### "Cannot update invocation template"
- Validate JSON syntax
- Ensure `__QUERY_PLACEHOLDER__` is present
- Check template doesn't exceed size limits

### "Endpoint unavailable"
- The endpoint may have been deleted in AWS
- Check endpoint status in AWS Bedrock console
- Verify your AWS credentials have access
- Re-import if necessary

---

## Advanced Features

### Custom Session Management

Include custom session handling:

```json
{
  "message": "__QUERY_PLACEHOLDER__",
  "session": {
    "id": "generated-by-codemie",
    "metadata": {
      "userId": "user123",
      "startTime": "2024-01-01T00:00:00Z"
    }
  }
}
```

### Multi-Turn Conversations

AgentCore Runtimes can maintain conversation context:
- Codemie manages the conversation ID
- Your runtime stores conversation history
- Each message includes conversation context

### Custom Headers

If your runtime requires custom headers:
- Configure them in AWS Bedrock console
- Headers are automatically included in invocations
- Cannot be customized per-request from Codemie

---

## Comparison with Traditional Agents

| Feature | Traditional Agents | AgentCore Runtimes |
|---------|-------------------|-------------------|
| **Configuration** | AWS Agent Builder UI | Custom code/config |
| **Invocation** | Standard format | Custom JSON template |
| **Flexibility** | Preset options | Fully customizable |
| **Streaming** | Built-in | Custom implementation |
| **Tooling** | AWS-managed | Custom integration |
| **Complexity** | Lower | Higher |
| **Use Case** | Standard agents | Custom architectures |

---

## Next Steps

- [Configure AgentCore Guardrails](./06-guardrail-configuration.md)
- [Use AgentCore in Workflows](../workflows/agentcore-integration.md)
- [Monitor AgentCore Performance](../assistants/monitoring.md)
- [Advanced AgentCore Patterns](../advanced/agentcore-patterns.md)