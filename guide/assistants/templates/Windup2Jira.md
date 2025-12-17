# Windup2Jira Assistant

## Overview

The **Windup2Jira Assistant** is a specialized assistant designed to process migration analysis reports from **Windup/MTR (Migration Toolkit for Runtimes)** and automatically create structured, organized Jira tickets. It transforms hundreds of individual migration issues into a manageable hierarchy of Epics and Tasks using an intelligent "Hybrid Grouping Strategy."

**Assistant Slug:** `amna-windup2jira-assistant`

**Categories:** Migration & Modernization

**Icon:** [Wind Turbine Animation](https://upload.wikimedia.org/wikipedia/commons/4/41/Breitenlee-VESTAS-V-52_wind_turbine_looped.gif)

---

## Purpose

This assistant bridges the gap between migration analysis tools (Windup/MTR) and project management by:

- **Processing Windup Reports**: Analyzing AllIssues.csv and issues.json files from Windup/MTR analysis
- **Intelligent Grouping**: Creating a two-level hierarchy (Epics by Category, Tasks by Rule ID)
- **Automated Ticket Creation**: Generating well-structured Jira Epics and Tasks with comprehensive descriptions
- **Consolidation**: Grouping multiple file-level issues into single, actionable tasks
- **Context Enrichment**: Supplementing ticket descriptions with additional context from detailed issue data

---

## Key Characteristics

### Hybrid Grouping Strategy

The assistant uses a two-level hierarchical approach:

1. **Level 1 - Epics by Category**: Groups issues by their category (e.g., Mandatory, Optional, Potential)
2. **Level 2 - Tasks by Rule ID**: Within each category, creates one task per unique rule ID, consolidating all affected files

This prevents ticket explosion (hundreds of individual tickets) while maintaining traceability.

### Dual Datasource Approach

- **Primary Source (`windup-allissues-csv`)**: Used for grouping, organization, and structure
- **Supplementary Source (`windup-issues-txt`)**: Used to enrich individual ticket descriptions with additional context

### Intelligent Ticket Construction

Each task includes:
- Rule ID and effort score
- Comprehensive description
- Complete list of all affected files
- Additional context from detailed issue data
- Proper linking to parent Epic

---

## Required Datasources

Before using this assistant, you must create two datasources in your AI-RUN environment:

### 1. windup-allissues-csv
- **Source File**: `AllIssues.csv` from Windup/MTR report
- **Datasource Name**: `windup-allissues-csv`
- **Format**: CSV
- **Contains**: issueId, ruleId, title, description, effort, category, file

### 2. windup-issues-txt
- **Source File**: `api/issues.json` from Windup/MTR report
- **Datasource Name**: `windup-issues-txt`
- **Format**: Text/String (rename from .json to .txt before upload)
- **Purpose**: Provides detailed context for enriching ticket descriptions
- **Note**: Due to strict JSON parsing rules, this file should be uploaded as a text file

---

## Prerequisites

1. **Jira Integration**: The Generic Jira tool must be properly configured and activated
2. **Windup/MTR Report**: A completed Windup or MTR analysis with generated reports
3. **Datasources Created**: Both required datasources uploaded to AI-RUN
4. **Jira Project Access**: Permissions to create Epics and Tasks in the target project
5. **Custom Fields Understanding**: Familiarity with your Jira project's custom field requirements

---

## Jira Configuration

Update the following settings in your assistant configuration:

```yaml
Project: YOUR_PROJECT_KEY
Reporter: {{current_user}}
Issue Types: Epic, Task
```

**Important**: Replace `CHANGEME!!!` placeholders with your actual Jira project key before use.

---

## Starting Prompt

To initiate the ticket creation process, use the following comprehensive prompt:

```
**Objective:**
Your task is to process the migration issues identified in the `windup-allissues-csv` datasource, which contains a list of issues captured by the Windup/MTR tool. You will then create a structured set of Jira tickets based on a "Hybrid Grouping Strategy" to ensure the issues are organized, manageable, and actionable for the development team. While grouping and organizing, always use the `windup-allissues-csv` datasource as your main reference. When drafting or editing individual Jira tickets, consult the `windup-issues-txt` datasource to supplement your descriptions or add extra insights about the specific issue you are working on.

**Input:**
* Access to the `windup-allissues-csv` datasource, which contains columns such as `issueId`, `ruleId`, `title`, `description`, `effort`, `category`, and `file`.
* Additional context available from the `windup-issues-txt` datasource, which you may use to enhance the descriptions of individual issues/tickets.

**Core Strategy: The Hybrid Grouping Model**
Instead of creating one ticket for each of the hundreds of items in the csv, you will group them intelligently. This involves a two-level hierarchy using Jira's Epics and Tasks:

1. **Level 1: Group by Category into Epics.**
   Use the `category` column from the `windup-allissues-csv` as the basis for creating Jira Epics. Each unique category becomes one Epic, providing a high-level classification of work.

2. **Level 2: Group by Rule ID into Tasks.**
   The `ruleId` also from the `windup-allissues-csv`, represents a specific type of issue (e.g., `hibernate-search-00790`). All items that share the same `ruleId` describe the same problem across different files. Create one Jira Task for each unique `ruleId` within a category, and link it to the relevant Epic.

**Execution Steps:**

1. **Parse the `windup-allissues-csv` datasource.** Load and read all the items from this primary source.

2. **Identify Unique Categories and Create Epics.**
   * Find all unique values in the `category` column using the `windup-allissues-csv` datasource.
   * For each unique category, create a Jira Epic.
   * **Epic Title:** `[MTR Migration] Address <Category Name> Issues` (e.g., `[MTR Migration] Address Mandatory Issues`).
   * **Epic Description:** "This Epic tracks the resolution of all issues classified as '<Category Name>' by the MTR analysis."

3. **Group Issues by Rule and Create Tasks.**
   * Iterate through your grouped data. For each unique `ruleId` within a category:
   * Create a single Jira Task.
   * **Link the Task** to the appropriate parent Epic you created in the previous step.

4. **Construct the Task Details.**
   For each task, consolidate all items that share the same `ruleId` using the `windup-allissues-csv` datasource. Then, query the `windup-issues-txt` datasource for that issue, and incorporate any useful additional information or context you find.
   
   * **Task Title:** Use the `title` from the csv. The title will be the same for all items with the same `ruleId`.
   * **Task Description:** Construct a detailed description using the following template:

**Rule ID:** {ruleId}
**Effort Score:** {effort}

**Description:**
{description}

---

**Affected Files:**
This issue has been identified in the following locations:
- {file_path_1}
- {file_path_2}
- {file_path_3}
- ... (list all unique file paths for this ruleId)

**Additional Information from windup-issues-txt:**
{Any relevant supplementary context found}

**Jira Configuration:**
* **Project:** `YOUR_PROJECT_KEY`
* **Reporter:** `youremail@company.com`
* **Issue Types:** Use `Epic` and `Task`.

**Final Output:**
The final output should be a series of Jira Epics and Tasks created in the specified project, reflecting the organized and grouped structure. After creation, provide a summary list of the Epics and Tasks created with clickable links to each.

When creating or editing each Jira ticket, combine data from both datasources—using the `windup-allissues-csv` as your main organizing reference, but always enrich your ticket details where possible with context from the `windup-issues-txt`.
```

---

## Operational Behavior

### Pre-Creation Reconnaissance
- Before creating tickets, the assistant explores existing Jira tickets in the project
- Learns the structure and naming conventions of typical tickets
- Identifies custom field requirements and patterns

### Adaptive Field Handling
- If custom field requirements block ticket creation, the assistant adapts
- Falls back to safer, more generic approaches
- Continues processing without stopping on field-related errors

### Context Enrichment
- Always checks `windup-issues-txt` datasource when creating/editing tickets
- Supplements descriptions with additional context where available
- Ensures tickets contain comprehensive information for developers

### Link Provision
- Always includes clickable links to created Jira tickets
- Provides summary of all created Epics and Tasks with links
- Enables easy verification and navigation

---

## Typical Workflow

1. **Datasource Preparation**
   - Upload AllIssues.csv as `windup-allissues-csv`
   - Rename api/issues.json to issues.txt and upload as `windup-issues-txt`

2. **Assistant Invocation**
   - Start conversation with the comprehensive prompt
   - Assistant parses the CSV datasource

3. **Epic Creation**
   - Identifies unique categories
   - Creates one Epic per category
   - Links to project

4. **Task Creation**
   - Groups issues by ruleId within each category
   - Creates one Task per unique ruleId
   - Links Tasks to parent Epics
   - Enriches descriptions with context from issues.txt

5. **Summary Delivery**
   - Provides list of all created Epics and Tasks
   - Includes clickable links for easy access
   - Reports any issues or adaptations made

---

## Example Output Structure

```
Epic: [MTR Migration] Address Mandatory Issues
├── Task: Replace javax.persistence with jakarta.persistence (15 files affected)
├── Task: Update Hibernate Search annotations (8 files affected)
└── Task: Migrate JAX-RS endpoints (22 files affected)

Epic: [MTR Migration] Address Optional Issues
├── Task: Consider modernizing logging framework (5 files affected)
└── Task: Review deprecated API usage (12 files affected)
```

---

## Use Cases

### 1. Application Migration Projects
- Java EE to Jakarta EE migrations
- Framework upgrades (Hibernate, Spring, etc.)
- Cloud-native transformations

### 2. Technical Debt Management
- Organizing large-scale refactoring efforts
- Tracking deprecation remediation
- Managing API migration tasks

### 3. Modernization Initiatives
- Breaking down complex migration reports into actionable work
- Providing development teams with structured, prioritized tasks
- Tracking migration progress through Jira workflows

### 4. Compliance and Audit
- Documenting all identified migration issues
- Maintaining traceability from analysis to resolution
- Creating audit trails for migration decisions

---

## Best Practices

### Before Starting
1. **Review Windup Report**: Understand the scope and categories of issues
2. **Configure Jira Project**: Ensure project exists and has appropriate workflows
3. **Test Datasources**: Verify both datasources are correctly uploaded and accessible
4. **Update Placeholders**: Replace all `CHANGEME` values with actual project details

### During Execution
1. **Monitor Progress**: Watch for any custom field issues or errors
2. **Verify Links**: Check that Epic-Task relationships are correctly established
3. **Review Descriptions**: Ensure context enrichment is working properly

### After Completion
1. **Verify Tickets**: Click through the provided links to spot-check created tickets
2. **Adjust Priorities**: Use Jira to set priorities based on effort scores and categories
3. **Assign Work**: Distribute tasks to development team members
4. **Track Progress**: Use Jira boards to monitor migration progress

---

## Troubleshooting

### Issue: Custom Field Errors
**Solution**: The assistant will automatically adapt and use generic fields. Review created tickets and manually populate custom fields if needed.

### Issue: Datasource Not Found
**Solution**: Verify datasource names exactly match `windup-allissues-csv` and `windup-issues-txt` (case-sensitive).

### Issue: Duplicate Tickets
**Solution**: Check if tickets already exist in the project. The assistant should detect existing tickets during reconnaissance.

### Issue: Missing Context
**Solution**: Ensure `windup-issues-txt` datasource contains the complete issues.json content and is accessible.

---

## Related Documentation

- **Windup/MTR**: [Red Hat Migration Toolkit for Runtimes](https://developers.redhat.com/products/mtr/overview)
- **Jira Integration**: See your AI-RUN Jira integration documentation
- **Generic Jira Tool**: Refer to AI-RUN Project Management toolkit documentation

---

## Notes

- This assistant is specifically designed for Windup/MTR reports but can be adapted for similar migration analysis tools
- The hybrid grouping strategy significantly reduces ticket count while maintaining full traceability
- Always review the first few created tickets to ensure the structure meets your team's needs
- Consider creating a test run in a sandbox Jira project before processing large reports
