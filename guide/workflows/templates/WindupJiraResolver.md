# WindupJiraResolver: Resolves Jira Tasks made from Windup's Report


## Overview
This document provides a guide to setting up and executing the WindupJiraResolver workflow. The primary purpose of this workflow is to automate the resolution of Jira tasks that have been generated from a Windup migration report. It does this by creating a new Git branch, applying the necessary code changes based on the Jira task description, and finally opening a Merge/Pull Request with the completed work.

This workflow streamlines the process of actioning Windup's findings, reducing manual intervention and accelerating your migration or modernization project.

## ⚠️ Warning

- Token Usage: Keep track of your token and budget usage by regularly checking the 
details via the "Usage details" button on the workflow-executions page.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address
- Branch Naming is Critical: The workflow is hardcoded to create a branch named windup-01. Before running the workflow for a second time on the same repository, you MUST change this branch name in the workflow's YAML configuration. Failure to do so will cause the workflow to fail or result in Git conflicts. See the "Re-running the Workflow" section for detailed instructions.
- Datasource & Integration Permissions: Ensure that the credentials used for your Git 
  and Jira 
  datasources and integrations have sufficient permissions. The Git user needs to be 
  able to create branches and open pull requests. The Jira user must have permission to read the specified Jira tasks.

## Steps for Run

Unlike workflows that run on your local machine, this workflow operates entirely 
within EPAM AI/Run™ using platform-native datasources & integrations for Git and Jira.

### 1. Prerequisite: Create Datasources & Integrations

The workflow needs to connect to your Git repository and your Jira instance. This is done via Datasources in AI/Run™.

*   **Git Datasource:**
    1.  Navigate to the "Datasources" section in your AI/Run™ project.
    2.  Create a new datasource for your Git provider (e.g., GitHub, GitLab).
    3.  Provide the necessary repository URL and credentials (e.g., a Personal Access Token).
    4.  Once created, copy the Datasource ID. You will need this in the next step.

*   **Jira & Git Integrations:**
    1.  Similarly, navigate to the "Integrations" section.
    2.  Create a new integration for Jira. The workflow uses the `generic_jira_tool`, 
        which requires a configured Jira integration.
    3.  Provide your Jira instance URL, username, and an API token.
    4.  Ensure this integration is correctly configured and enabled.
    5.  Repeat the above steps to make a Git Integration.

### 2. Configure the Workflow Template

Before you can run the workflow, you must link it to the datasources you just created.

1.  In AI/Run™, go to Workflow templates and find the `WindupJiraResolver` template.
2.  Create a new workflow from the template or edit your existing one.
3.  You will need to edit the workflow's YAML definition to insert your Git Datasource ID.
4.  Locate the `datasource_ids` fields within the `brancher` and `jira_resolver` assistants.
5.  Replace the placeholder `<GIT_DATASOURCE_ID>` with the actual ID you copied in the previous step.

    **Example (before):**
    ```yaml
    - id: jira_resolver
      ...
      datasource_ids: [ <GIT_DATASOURCE_ID> ]
    ```

    **Example (after):**
    ```yaml
    - id: jira_resolver
      ...
      datasource_ids: [ "dsrc-xxxxxxxxxxxx" ]
    ```
6.  Save the changes to the workflow.

### 3. Run the Workflow

1.  Navigate to the workflow's page and click "Run".
2.  You will be prompted to provide input. In the prompt, specify the Jira Task(s) you want the workflow to resolve.
3.  **Example Prompt:** `I want you to resolve Jira tickets WINDUP-42 and WINDUP-43.`
4.  The workflow will now start. It will first create a new branch, then read the content of each Jira ticket, and finally make the necessary code changes and commit them to the new branch.

### 4. View the Results

Once the workflow completes successfully, its final act is to create a Pull Request (or Merge Request) in your configured Git repository.

1.  Navigate to your Git repository (e.g., GitHub, GitLab).
2.  Go to the "Pull Requests" section.
3.  You should see a new PR titled `windup-01` (or whatever name you configured) with all the committed changes, ready for your review.

### 5. Re-running the Workflow (Important!)

As highlighted in the warning, you must change the branch name before running this workflow again.

1.  Edit the `WindupJiraResolver` workflow's YAML.
2.  Go to the first state, `branching`.
3.  Modify both the `task` and the `output_schema` to use a new, unique branch name.

    **Change this:**
    ```yaml
    states:
      - id: branching
        assistant_id: brancher
        task: |
          1. Create a new branch named 'windup-01' from the main branch...
          ...
        output_schema: |
          {
          "branch_name": "windup-01"
          }
    ```

    **To this (for example):**
    ```yaml
    states:
      - id: branching
        assistant_id: brancher
        task: |
          1. Create a new branch named 'windup-02' from the main branch...
          ...
        output_schema: |
          {
          "branch_name": "windup-02"
          }
    ```
4.  Save the workflow. You can now run it again to resolve a new set of Jira tasks.
