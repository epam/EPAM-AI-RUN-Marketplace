
# AWS AgentCore: Connect an A2A Agent to AI/Run Platform

## Overview
This guide explains how to connect an **AWS AgentCore A2A agent** to the **AI/Run Platform** by:
- Building the **agent invocation endpoint URL** using your agent **ARN** (URL-encoded)
- Creating an **Integration** in AI/Run with **Credential Type: A2A** and **Authentication Type: AWS Signature**
- Creating a **Remote Assistant** in AI/Run that uses the URL + Integration

---

## ⚠️ Warning
- The agent **ARN must be URL-encoded** before inserting it into the endpoint path.
- Use **temporary credentials** only when required (they expire). If you use temporary credentials, you must provide **AWS Session Token**.
- Make sure **AWS Service Name** is set to **`bedrock-agentcore`**
- Make sure you use the **correct AWS Region**:
  - The endpoint host must match your region: `bedrock-agentcore.{region}.amazonaws.com` (for example, `bedrock-agentcore.eu-central-1.amazonaws.com`)
  - The Integration’s **AWS Region** must be the same region where your AgentCore runtime exists

---

## Steps

### 1. Copy the Agent ARN in AWS
1. Open the AWS console.
2. Navigate to your AgentCore A2A agent. (Amazon Bedrock AgentCore -> Runtime -> "Your Agent")
3. Copy the **Agent ARN**.

---

### 2. URL-encode the ARN
You must URL-encode the ARN before putting it into the endpoint path.

- Example (conceptual):
  - Raw ARN: `arn:aws:...:agent/...`
  - URL-encoded ARN: `arn%3Aaws%3A...%3Aagent%2F...`

Use any URL-encoding method you trust (online encoder, IDE utility, scripting tool), then keep the encoded value for the next step.

---

### 3. Build the endpoint URL that invokes the agent
Insert the **URL-encoded ARN** into the agent invocation endpoint path.

- **Endpoint URL template** (replace placeholders):

```text
https://bedrock-agentcore.{region}.amazonaws.com/runtimes/{EncodedRuntimeArn}/invocations/
```

- **Required inputs**:
  - `{region}`: AWS region where your AgentCore runtime exists (for example, `eu-central-1`)
  - `{EncodedRuntimeArn}`: your agent/runtime ARN after **URL-encoding**

> Note: The critical part is that the ARN inside the path is **URL-encoded**.

---

### 4. Create an A2A Integration in AI/Run Platform
Create an integration with the following settings:

- **Credential Type**: `A2A`
- **Authentication Type**: `AWS Signature`

Specify either **temporary** or **permanent** AWS credentials:
- **AWS Region**
- **AWS Access Key**
- **AWS Secret Key**
- **AWS Session Token** (required for temporary credentials)
- **AWS Service Name**: `bedrock-agentcore`

Save the integration.

---

### 5. Create a Remote Assistant using the URL + Integration
1. In AI/Run Platform, create a new **Remote Assistant**.
2. Set the **Remote URL** to the endpoint URL from **Step 3**.
3. Select the **Integration** created in **Step 4**.
4. Fetch the **assistant card**.
5. Save the assistant.

After saving, the assistant will appear in your assistants list — you can open it and start chatting with it.
