# Excel Assistant

## Overview

The **Excel Assistant** is a specialized AI assistant designed for processing and analyzing large Excel files using the pandas library. It leverages the `marlonluo2018/pandas-mcp-server` MCP server to provide powerful data manipulation, analysis, and visualization capabilities for Excel and CSV files.

**Slug**: `amna-excel-assistant`  
**Categories**: Data Analytics, Migration & Modernization  
**Icon**: Excel Logo

## Purpose

This assistant enables users to:
- Load and inspect large Excel/CSV files
- Query and filter data using pandas operations
- Generate statistical summaries and metadata insights
- Create interactive Chart.js visualizations
- Perform complex data analysis without manual coding

## Key Characteristics

### Available Tools

The assistant has access to three primary tools from the pandas MCP server:

1. **`_read_metadata_tool`**: Inspects Excel/CSV file metadata including sheet names, column names, data types, and basic statistics
2. **`_run_pandas_code_tool`**: Executes pandas code safely with validation and error checking
3. **`_generate_chartjs_tool`**: Creates interactive Chart.js visualizations and saves them as HTML files

### Operational Behavior

- **Metadata-First Approach**: Always inspects file metadata (especially sheet names) before executing pandas operations
- **File Path Persistence**: Tracks original file paths to avoid issues with temporary file references
- **Detailed Analysis**: Provides in-depth, comprehensive answers rather than brief summaries
- **Table Formatting**: Presents results in table format when it improves readability
- **Autonomous Operation**: Executes queries and analysis tasks without requiring confirmation (visualization generation only on explicit request)

### Data Processing Capabilities

- Multi-sheet Excel file handling
- Complex filtering and querying operations
- Statistical analysis and aggregations
- Data transformation and manipulation
- Column-based operations and comparisons
- Conditional logic and data extraction

## MCP Server Configuration

### Installation Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/marlonluo2018/pandas-mcp-server
   ```

2. **Configure Codemie Plugins**:
   
   Add the following configuration to `~/.codemie/config.json`:

   ```json
   {
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
   ```

3. **Update Paths**: Replace `/path/to/` with your actual installation directory

4. **Restart Codemie Plugins**: Ensure the MCP server is loaded with the updated configuration

### Configuration Parameters

- **command**: Python interpreter to execute the server
- **args**: Path to the `server.py` script in the cloned repository
- **transport**: Communication method (stdio for standard input/output)
- **workingDir**: Root directory of the pandas-mcp-server installation
- **env.LOG_LEVEL**: Logging verbosity (INFO, DEBUG, WARNING, ERROR)

## Usage Context

### Prerequisites

- Codemie-plugins running with the pandas MCP server configured
- Python environment with pandas library installed
- Excel or CSV files accessible to the assistant
- Assistant created using this template with the Plugin toolkit enabled

### Example Starting Prompts

**Basic File Inspection**:
```
Load /path/to/data/sales_report.xlsx and show me the available sheets and columns
```

**Complex Query**:
```
Load /path/to/data/assessment_report_2025-08-05.xlsx, from this excel file, 
get the list of all database schemas where complexity of the stored procedures 
is bigger or equal to 3L
```

**Statistical Analysis**:
```
Load /path/to/data/customer_data.csv and provide summary statistics for all 
numeric columns, grouped by customer region
```

**Visualization Request**:
```
Load /path/to/data/monthly_sales.xlsx and create a bar chart showing sales 
by product category for Q4 2024
```

## Operational Workflow

### Standard Analysis Flow

1. **Load File**: User provides file path and analysis request
2. **Inspect Metadata**: Assistant uses `_read_metadata_tool` to understand file structure
3. **Execute Query**: Assistant runs pandas code via `_run_pandas_code_tool` to extract/analyze data
4. **Format Results**: Results are presented in tables or structured format
5. **Generate Visualizations** (if requested): Creates Chart.js HTML files using `_generate_chartjs_tool`

### File Path Handling

The assistant is designed to handle file path issues intelligently:
- Tracks original file paths from conversation history
- Avoids temporary file path references that may become invalid
- Backtracks through conversation to locate explicit file paths when needed

## Best Practices

### For Users

- **Provide Full Paths**: Always use absolute file paths when loading Excel/CSV files
- **Be Specific**: Clearly describe the columns, conditions, and operations you need
- **Request Tables**: Ask for table formatting when dealing with multiple results
- **Explicit Visualization**: Only request charts when you specifically want visual output

### For Optimal Results

- Start with metadata inspection for unfamiliar files
- Use clear column names and conditions in queries
- Break complex analysis into multiple steps if needed
- Verify sheet names before querying multi-sheet workbooks

## Example Use Cases

### Data Extraction
- Filter rows based on multiple conditions
- Extract specific columns matching criteria
- Find unique values or distinct records
- Identify outliers or anomalies

### Statistical Analysis
- Calculate summary statistics (mean, median, std dev)
- Group data by categories and aggregate
- Compare values across different segments
- Perform correlation analysis

### Data Transformation
- Merge or join data from multiple sheets
- Pivot and reshape data structures
- Create calculated columns
- Clean and normalize data

### Reporting & Visualization
- Generate summary reports in table format
- Create interactive charts (bar, line, pie, scatter)
- Export analysis results
- Build dashboard-ready visualizations

## Security Considerations

- **File Access**: The assistant can only access files within directories permitted by the MCP server configuration
- **Code Execution**: Pandas code is executed with safety checks and validation
- **Data Privacy**: All processing happens locally; no data is sent to external services
- **Read-Only by Default**: The assistant focuses on reading and analyzing data, not modifying source files

## Related Documentation

- **MCP Server Repository**: [marlonluo2018/pandas-mcp-server](https://github.com/marlonluo2018/pandas-mcp-server)
- **Pandas Documentation**: [pandas.pydata.org](https://pandas.pydata.org/)
- **Chart.js Documentation**: [chartjs.org](https://www.chartjs.org/)
- **Codemie Plugins Configuration**: Refer to your local Codemie documentation for MCP server setup

## Notes

- This assistant is optimized for **large Excel files** that may be difficult to process manually
- The pandas library provides powerful data manipulation capabilities beyond basic Excel functions
- Interactive Chart.js visualizations are saved as standalone HTML files that can be opened in any browser
- The assistant maintains conversation context to handle follow-up questions about the same dataset
