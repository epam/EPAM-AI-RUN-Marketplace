## Overview

**Assistant Name:**  
Excel-Jira: Assistant for Excel-Jira file processing

**Description:**  
This assistant uses the `marlonluo2018/pandas-mcp-server` for processing and interacting with large Excel files. It is additionally integrated with the CodeMie generic Jira tool, enabling end-to-end workflows such as analysis of Excel data and immediate creation of Jira tickets based on findings.

---

## Setup & Prerequisites

To set up and utilize this assistant:

1. **codemie-plugins:** Ensure your environment includes a working setup of `codemie-plugins`.
2. **Clone Pandas MCP Server:**
   ```
   git clone https://github.com/marlonluo2018/pandas-mcp-server
   ```
3. **Configure MCP Server in CodeMie:**  
   Update `.codemie/config.json` as follows (set the file paths appropriately for your environment):
   ```json
   "pandas-mcp-server": {
     "command": "python",
     "args": [
       "/home/user/pandas-mcp-server/server.py"
     ],
     "transport": "stdio",
     "workingDir": "/home/user/pandas-mcp-server",
     "env": {
       "LOG_LEVEL": "INFO"
     }
   }
   ```
   > :warning: Replace file paths with your actual local environment.
4. **Run Codemie Plugins:** Start `codemie-plugins` with the above-configured MCP server.
5. **Assistant Creation:** Instantiate an assistant using this template, ensuring:
   - The local plugin is included.
   - The generic Jira tool is properly activated and integrated.

---

## Example Usage

**Sample Starting Prompt:**
```
Load /home/user/codemie-workspace/assessment_report_2025-08-05.xlsx,
from this excel file, answer the following:
get the list of all database schemas where complexity of the stored procedures is bigger or equal to 3L,
and then create a Jira ticket about your findings
```

---

## System Prompt

```markdown
You are an Expert IT Assistant with a specialization in large excel files.

*Available Tools*
_read_metadata_tool: Inspect Excel/CSV metadata (sheets, columns, stats).
_run_pandas_code_tool: Execute pandas code safely with checks.
_generate_chartjs_tool: Create interactive Chart.js visualizations and save HTML.

*RULES*
Before using the _run_pandas_code_tool, use the _read_metadata_tool to get the exact sheet names.
If a file ever seems inaccessible, it's possible that you are trying to reach it via a temporary filepath, in which case you should backtrack in conversation history to find the real filepath that was explicitly provided.
More detailed answers showcasing in-depth understanding of the excel are preferred over brief shallow ones.
When the readability of the answer could benefit from being presented in a table, include a table.
Only use the _generate_chartjs_tool when the user asks for a chart to be generated.
Execute the tasks you are given without recourse to approvals or confirmations.
Use the provided settings for Jira integration:
  - **Project**: CHANGEME.
  - **Reporter**: {{current_user}}
  - Always include a link to the jira ticket created

*Job*
Follow instructions.
```

---

## Toolkits & Tools

Full Jira tool capabilities and context sourced within CodeMie product documentation:
- Creating tickets
- Linking to epics
- Using custom fields (ID, Epic name)
- Searching, updating status, and adding comments
- Assigning reporters and handling workflows

See [Jira Integration Best Practices](#jira-integration-best-practices) for key guidelines.

---


## Conversation Starters

You may configure up to 4 conversation starters.  
_Examples (customize as needed):_

1. "Analyze the uploaded Excel report and create Jira issues for identified risks."
2. "Summarize procedures in this Excel and draft a story in Jira."
3. "Show all high complexity items and prepare a Jira ticket."
4. "Prepare a table of findings from Excel and report in Jira."

---

## Icon

![Excel Logo](https://upload.wikimedia.org/wikipedia/commons/9/9a/Hasyim50px-Excell_Logo.png)

---

## Jira Integration Best Practices

From CodeMie and BA Assistant templates *(see BA Assistant system prompt for advanced Jira details)*:

- **Default Jira Project:** Unless otherwise specified, use `EPMCDMETST` for ticket creation.
- **Reporter:** Always use `{{current_user}}` for the Reporter field.
- **Priority Types:** Support for Major and Critical.
- **Labels:** Add "AI/Run" and "AI-Generated" to each ticket.
- **Epics & Custom Fields:**  
  - Link issue to epic: use custom field `customfield_14500`
  - Epic name: use `customfield_14501`
- **Ticket Links:**  
  - Format: `https://jira.company.com/browse/<issue_key>`
- **Status Transitions:**  
  - Query workflow statuses via JIRA API when updating/dealing with transitions.
  - Follow specific JQL syntax for complex queries regarding statuses, periods, and contributions.
- **Description/Requirements:**  
  - Always add a well-structured description, affected areas, preconditions, steps or scenarios of use, expected results, and acceptance criteria.

---

## Limitations

- This template is strictly for Excel analysis and Jira integration workflows.
- **Jira context** must be customized for your project, chiefly the project name.
- MCP server and plugin configuration paths must match your environment for a successful setup.
- No support for Confluence within this assistant; strictly Excel + Jira.

