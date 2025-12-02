# Excel Assistant Template Documentation

## Overview

**Assistant Name:**  
Excel: Assistant for Excel file processing

**Description:**  
This assistant leverages the `marlonluo2018/pandas-mcp-server` for interactive processing of large Excel files. It provides streamlined operations for data analysis, querying, and reporting tasks by connecting CodeMie plugins to a local or remote Pandas MCP server.

---

## Setup & Prerequisites

To utilize this assistant, follow these setup instructions:

1. **Codemie Plugins:** Ensure you have a working setup of `codemie-plugins`.
2. **MCP Server:** Clone the Pandas MCP server:
   ```
   git clone https://github.com/marlonluo2018/pandas-mcp-server
   ```
3. **Configure Codemie:**  
   Add an entry for the server in your `.codemie/config.json`:
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
   > :warning: **Update all file paths to reflect your local environment.**
4. **Run Plugins:** Start `codemie-plugins` configured with the Pandas MCP server.
5. **Assistant Creation:** Create an assistant based on this template, ensuring the local plugin is included.

---

## Usage Example

**Sample Starting Prompt:**
```
Load /home/user/codemie-workspace/assessment_report_2025-08-05.xlsx,
from this excel file, answer the following:
get the list of all database schemas where complexity of the stored procedures is bigger or equal to 3L
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

*Job*
Follow instructions.
```

---

## Toolkits & Tools

| Toolkit | Tool Name               | Purpose/Label |
|---------|-------------------------|---------------|
| Plugin  | Plugin                  | Plugin        |

- **_read_metadata_tool**  
  Inspects Excel/CSV file metadata: sheets, columns, stats.

- **_run_pandas_code_tool**  
  Executes Python pandas code in a safe, controlled environment.

- **_generate_chartjs_tool**  
  Generates Chart.js interactive HTML visualizations when requested by user.

These tools are accessible via the declared Plugin toolkit. Their integration is handled via CodeMie plugin configuration and MCP server communication.

---


## Conversation Starters

You may configure up to 4 conversation starters for quick user onboarding.  
_Example starters (not present in the template, drafts for user customization):_

1. "Load and summarize key metrics from a new Excel file."
2. "Find all rows where the status column is marked as 'Failed'."
3. "Generate a bar chart for total sales per region from the uploaded Excel."
4. "Show column statistics and metadata for the provided sheet."

---

## Icon

![Excel Logo](https://upload.wikimedia.org/wikipedia/commons/9/9a/Hasyim50px-Excell_Logo.png)

---

## Additional Notes

- **File Handling:** Only the latest uploaded file is used for queries unless a specific file name is referenced in the prompt.
- **Integration:** User must manage MCP server lifecycles and ensure correct plugin configuration for stable operations.
- **Global Availability:** This assistant template is globally enabled (`is_global: true`) and can be accessed across projects.

---


## Limitations

- Only information in template and linked plugin instructions is relevant to this assistant's function.
- Assistant is designed specifically for Excel (and similar CSV) processing tasks.
- Customization may be required for file paths and environment setup as per local deployment.
