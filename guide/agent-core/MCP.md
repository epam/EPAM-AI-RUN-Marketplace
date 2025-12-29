
# AWS AgentCore: Connect an MCP Server to an Assistant in AI/Run Platform

## Overview
This guide explains how to connect an **MCP server deployed on AWS AgentCore** to an existing assistant in the **AI/Run Platform** by:
- Building the **AgentCore runtime invocation URL** from your MCP **ARN** (URL-encoded)
- Adding the MCP server configuration in **Assistant → Settings → External Tools → MCP Servers**
- Creating an **Integration** in AI/Run (Credential Type: **MCP**, Authentication Type: **AWS Signature**) and testing it

For deploying MCP on AgentCore, see the **Bedrock AgentCore Developer Guide**: [`bedrock-agentcore-dg.pdf` (page 127)](https://docs.aws.amazon.com/pdfs/bedrock-agentcore/latest/devguide/bedrock-agentcore-dg.pdf#page=127).

---

## ⚠️ Warning
- The MCP **ARN must be URL-encoded** before inserting it into the runtime invocations URL.
- Make sure you use the **correct AWS Region**:
  - The endpoint host must match your region: `bedrock-agentcore.{region}.amazonaws.com`
  - Your credentials/integration **AWS_REGION** must match the same region where the runtime exists
- Make sure the **AWS service name** used for signing is **`bedrock-agentcore`**.

---

## Steps

### 1. Copy the MCP Runtime ARN in AWS
1. Open the AWS console.
2. Navigate to your AgentCore runtime for the MCP server.
3. Copy the **Runtime ARN** for your MCP.

---

### 2. URL-encode the ARN
URL-encode the Runtime ARN before putting it into the endpoint path.

- Example (conceptual):
  - Raw ARN: `arn:aws:...:runtime/...`
  - URL-encoded ARN: `arn%3Aaws%3A...%3Aruntime%2F...`

---

### 3. Build the MCP invocation URL
Insert the **URL-encoded Runtime ARN** into the URL below.

- **URL template** (replace placeholders):

```text
https://bedrock-agentcore.{region}.amazonaws.com/runtimes/{EncodedRuntimeArn}/invocations?qualifier=DEFAULT
```

- **Required inputs**:
  - `{region}`: AWS region where your AgentCore runtime exists (for example, `eu-central-1`)
  - `{EncodedRuntimeArn}`: your runtime ARN after URL-encoding

---

### 4. Add the MCP Server configuration to your assistant
1. In AI/Run Platform, open the assistant you want to connect to the MCP server.
2. Go to **Settings**.
3. Open **External Tools** tab.
4. Open **MCP Servers**.
5. Manually add the MCP server configuration.

The MCP configuration is a JSON object like this:

```json
{
  "url": "https://bedrock-agentcore.{region}.amazonaws.com/runtimes/{EncodedRuntimeArn}/invocations?qualifier=DEFAULT",
  "auth_token": null
}
```

---

### 5. Create an Integration for MCP in AI/Run Platform
Create an integration with the following settings:

- **Credential Type**: `MCP`

You will need:
- **AWS_SERVICE**: `bedrock-agentcore`
- **AWS_REGION**
- **AWS_ACCESS_KEY_ID**
- **AWS_SECRET_ACCESS_KEY**

---

### 6. Select and test the integration
1. In the **MCP Servers** settings, select your created integration from the list.
2. Click **Test Integration** and make sure the test is successful.

---

### 7. Save assistant settings and verify tools
1. Save the MCP configuration and the assistant’s settings.
2. Open a chat with your assistant.
3. Verify available tools from the MCP (for example, ask: “Show me tools”).
