## EPAM AI/Run™ for AWS - Workflows Overview

EPAM AI/Run™ for AWS offers powerful workflow capabilities that allow you to automate complex tasks by chaining together multiple AI assistants. Workflows enable you to create sequential or autonomous processes that can handle sophisticated business logic and multi-step operations.

### What Are Workflows?

Workflows in EPAM AI/Run™ for AWS are structured sequences of AI assistant interactions designed to accomplish complex tasks by breaking them down into manageable steps. Each step can involve different assistants with specialized capabilities, working together toward a common goal.

### Types of Workflow Modes

The platform supports two primary workflow modes:

- **Sequential Mode**: Provides full control where you explicitly define each workflow step, choosing specific assistants and setting precise execution order. Ideal for tasks requiring detailed, orderly execution where sequence matters.

- **Autonomous Mode**: Offers a simplified workflow experience where the system's AI handles assistant selection and state management automatically. Perfect for when you want efficiency without detailed setup.

- **AWS Bedrock Workflows**: These leverage AWS Bedrock Agents with Knowledge Bases to create powerful workflows directly within the AWS environment. They can be integrated with EPAM AI/Run™ for AWS for a seamless experience across platforms.

## ⚠️ Warning
1. Do not connect too many plugins at once.
2. A workflow that uses plugin integration cannot be simultaneously connected to multiple computers.

### Using workflows across multiple projects
If you want to use the same workflow simultaneously in different projects:
1. Create a copy of the workflow for your own project (your@email.com)
2. Create a plugin integration specifically for your project (your@email.com)

### Creating a Workflow

1. Navigate to the **Workflows** tab in EPAM AI/Run™ for AWS
2. Click **Create Workflow**
3. Configure the workflow settings:
   - **Project**: Select your project (typically pre-populated)
   - **Shared with Project Team**: Toggle sharing preferences
   - **Name**: Enter a descriptive workflow name
   - **Description**: Provide a clear purpose for the workflow
   - **Icon URL**: (Optional) Add an icon for visual identification
   - **Workflow Mode**: Choose between Sequential or Autonomous
   - **Supervisor prompt**: Define context that applies to all assistants
   - **YAML Configuration**: For Sequential mode, define the workflow structure

4. Click **Create** to finish

### YAML Configuration Structure

For Sequential workflows, the YAML configuration includes:

1. **Assistants Section**:
   ```yaml
   assistants:
     - id: analyst_assistant  # Unique identifier within workflow
       assistant_id: business_analyst  # System ID of the assistant
       model: <model_which_was_import>  # Optional, specifies model to use
2. **States Section**:
   ```yaml
   states:
     - id: requirements_analysis
       assistant_id: analyst_assistant
       task: "Analyze the requirements provided"
       output_schema: |
         {
           "category": "Name of requirement category",
           "analysis": "Detailed analysis description"
         }
       next:
         - id: create_tickets
         
     - id: create_tickets
       assistant_id: jira_assistant
       task: "Create Jira tickets based on requirements analysis"
       input: "{{requirements_analysis.output}}"
       output_schema: |
         {
           "tickets_created": ["PROJ-123", "PROJ-124"],
           "summary": "Summary of created tickets"
         }
       next:
         - id: send_notification


### Creating a AWS Workflow
1. Create an AWS integration by following the instructions in the project guide located at **integration/README.md**
2. Follow the official AWS documentation to [Create and configure workflow - Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/flows-create.html)
3. Install workflow

## Executing Workflows

1. Navigate to the **Explore Workflows** page
2. Find your workflow and click **Start Execution**
3. Enter the initial prompt that will trigger the workflow
4. Monitor the execution progress in real-time
5. View the final results when the workflow completes

## Managing Workflow Executions

- **Monitoring**: Track the progress of active workflows in real-time
- **History**: Review past workflow executions with detailed metrics
- **Rerun**: Execute the same workflow again with the same or modified inputs
- **Export**: Download workflow execution results as a zip archive containing structured markdown files

## Export Functionality

When exporting workflow executions:

1. The system generates a zip archive with markdown files for each step
2. Files follow the naming pattern: `step_name_status.md`
3. The archive is named: `workflow_name_execution_datetime_execution_id.zip`

## Best Practices

- Start with clear objectives before creating workflows
- Create and configure assistants before adding them to workflows
- Test individual steps before combining them in a workflow
- Use the Supervisor prompt to provide shared context
- For complex logic, leverage conditional branching in Sequential mode
- Monitor execution costs through the token usage metrics