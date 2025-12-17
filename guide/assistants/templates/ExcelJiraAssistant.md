# Excel-Jira Assistant

## Overview

The **Excel-Jira Assistant** is a specialized assistant that combines Excel file processing capabilities with Jira ticket creation. It uses the `marlonluo2018/pandas-mcp-server` MCP server to analyze large Excel files and the Generic Jira integration to automatically create tickets based on findings.

**Assistant Slug**: `amna-excel-jira-assistant`

**Repository**: [marlonluo2018/pandas-mcp-server](https://github.com/marlonluo2018/pandas-mcp-server)

## Purpose

This assistant is designed to:
- Analyze large Excel files using pandas
- Extract insights and identify issues from spreadsheet data
- Automatically create Jira tickets based on analysis findings
- Generate reports that combine data analysis with issue tracking
- Streamline workflows that require both data inspection and ticket creation

## Key Characteristics

### Available Tools

The assistant has access to two distinct toolkits:

#### 1. Pandas MCP Server Tools
- **`_read_metadata_tool`**: Inspect Excel/CSV metadata (sheets, columns, statistics)
- **`_run_pandas_code_tool`**: Execute pandas code safely with validation checks
- **`_generate_chartjs_tool`**: Create interactive Chart.js visualizations and save as HTML

#### 2. Jira Integration
- **`generic_jira_tool`**: Create, update, and manage Jira tickets
- Configured with project-specific settings
- Automatic reporter assignment using `{{current_user}}`

### Operational Behavior

1. **Metadata-First Approach**: Always inspects file metadata before running pandas code to ensure accurate sheet names and column references
2. **File Path Tracking**: Maintains awareness of original file paths vs. temporary paths in conversation history
3. **Detailed Analysis**: Provides in-depth understanding of Excel data rather than superficial summaries
4. **Table Formatting**: Presents data in tables when it improves readability
5. **Chart Generation**: Only creates visualizations when explicitly requested
6. **Autonomous Execution**: Executes tasks without requiring approvals or confirmations
7. **Jira Link Inclusion**: Always includes clickable links to created Jira tickets

### Jira Configuration

The assistant uses the following Jira settings:
- **Project**: Configurable (set to your project key, e.g., "PROJ")
- **Reporter**: `{{current_user}}` (automatically set to the current user)
- **Ticket Links**: Always included in responses for easy access

## MCP Server Configuration

To use this assistant, you need to configure the pandas MCP server in your `~/.codemie/config.json`:

```json
{
  "mcpServers": {
    "pandas-mcp-server": {
      "command": "python",
      "args": [
        "/path/to/pandas-mcp-server/server.py"
      ],
      "transport": "stdio",
      "workingDir": "/path/to/pandas-mcp-server",
      "env": {
        "LOG_LEVEL": "INFO"
      }
    }
  }
}
```

**Note**: Replace `/path/to/` with your actual installation path.

## Prerequisites

1. **Codemie-plugins**: Working installation with MCP server support
2. **Pandas MCP Server**: Cloned from [GitHub repository](https://github.com/marlonluo2018/pandas-mcp-server)
3. **Jira Integration**: Generic Jira tool properly configured with a functional integration
4. **Assistant Configuration**: Assistant created with both the Plugin toolkit and Generic Jira tool enabled

## Installation Steps

1. Ensure you have a working setup of codemie-plugins
2. Clone the pandas MCP server:
   ```bash
   git clone https://github.com/marlonluo2018/pandas-mcp-server
   ```
3. Add the configuration to your `~/.codemie/config.json` (see configuration section above)
4. Update the file paths in the JSON to match your local installation
5. Configure the Generic Jira integration in your Codemie workspace
6. Create an assistant based on this template with both toolkits enabled
7. Set the Jira project key in the assistant configuration (replace "CHANGEME")

## Example Usage

### Basic Excel Analysis with Jira Ticket Creation

```
Load /path/to/assessment_report_2025-08-05.xlsx, from this excel file, 
get the list of all database schemas where complexity of the stored procedures 
is bigger or equal to 3L, and then create a Jira ticket about your findings
```

### Migration Assessment Report

```
Analyze the migration assessment Excel file at /path/to/migration_assessment.xlsx.
Identify all applications with high risk scores (>7) and create a Jira epic 
to track the migration of these high-risk applications.
```

### Data Quality Issues

```
Load /path/to/data_quality_report.xlsx and find all records with missing 
critical fields. Create individual Jira tickets for each data quality issue 
found, grouped by table name.
```

### Compliance Audit

```
From the compliance audit Excel at /path/to/audit_2025.xlsx, extract all 
non-compliant items and create a Jira ticket with a summary table of findings, 
including severity levels and affected systems.
```

## Typical Workflow

1. **Load Excel File**: Assistant loads the specified Excel file
2. **Inspect Metadata**: Automatically checks sheets, columns, and data types
3. **Analyze Data**: Executes pandas code to extract relevant information
4. **Format Results**: Presents findings in tables or structured format
5. **Create Jira Ticket**: Automatically creates ticket(s) based on analysis
6. **Provide Links**: Returns clickable links to created Jira tickets

## Use Cases

### 1. Audit Reporting
- Analyze audit results from Excel reports
- Automatically create tickets for identified issues
- Track remediation efforts in Jira

### 2. Migration Tracking
- Process migration assessment spreadsheets
- Create tickets for complex migration items
- Generate reports on migration complexity

### 3. Compliance Management
- Review compliance reports in Excel format
- Create tickets for non-compliant items
- Maintain audit trail in Jira

### 4. Data Quality Monitoring
- Identify data quality issues from Excel reports
- Create tickets for data cleansing tasks
- Track data quality improvements

### 5. Project Planning
- Extract project requirements from Excel
- Create Jira epics and stories automatically
- Link related items based on spreadsheet relationships

## Key Differences from Standard Excel Assistant

| Feature | Excel Assistant | Excel-Jira Assistant |
|---------|----------------|---------------------|
| **Jira Integration** | ❌ Not available | ✅ Full integration |
| **Ticket Creation** | ❌ Manual only | ✅ Automated |
| **Use Case** | Data analysis only | Analysis + issue tracking |
| **Toolkits** | Plugin only | Plugin + Project Management |
| **Output** | Analysis results | Analysis + Jira tickets |

## Best Practices

1. **Provide Full File Paths**: Always use absolute paths to Excel files
2. **Specify Jira Project**: Ensure the project key is correctly configured
3. **Clear Analysis Criteria**: Define what findings should trigger ticket creation
4. **Review Metadata First**: Let the assistant inspect the file structure before complex queries
5. **Batch Operations**: For multiple tickets, clearly specify grouping criteria
6. **Include Context**: Provide enough context for meaningful Jira ticket descriptions

## Related Documentation

- **Pandas MCP Server**: [GitHub Repository](https://github.com/marlonluo2018/pandas-mcp-server)
- **Pandas Documentation**: [pandas.pydata.org](https://pandas.pydata.org/)
- **Chart.js**: [chartjs.org](https://www.chartjs.org/)
- **Jira REST API**: [Atlassian Documentation](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)
- **Standard Excel Assistant**: `guide/assistants/templates/ExcelAssistant.md`

## Categories

- Data Analytics
- Migration & Modernization
- Project Management
