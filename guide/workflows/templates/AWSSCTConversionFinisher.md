# AWS SCT Conversion Finisher

## Overview
This workflow is designed to complete the conversion of scripts from Microsoft SQL Server (MS SQL) to PostgreSQL (PGSQL) using the output from the AWS Schema Conversion Tool (SCT).  
Additionally, it integrates AI-driven assistants to handle complex or unsupported features, ensuring a smooth and efficient conversion process.

---

## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 13.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address

---

## Prerequisites & Environment Setup

1. **Install Python 3.12 or higher**
2. **Install uvx (for codemie-plugins)**
   ```bash
   pip install uv
   ```
3. **Install Node.js 22 or higher**
4. **Install codemie-plugins**
   ```bash
   pip install codemie-plugins
   ```
5. **Configure connection to NATS catalogue**  
   Edit `<user_home_directory>\.codemie\config.json`:
   ```json
   {
     "PLUGIN_KEY": "<Any value>",
     "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422"
   }
   ```
6. **Create plugin project integration on AI/Run™**
    - Use value from `config.json` (“PLUGIN_KEY”).
    - Set "Alias" property to: `demo-plugin-integration`.
7. **Organize your files**
    - Create a folder for all your scripts and required files.
8. **Initialize Airun folder**
    - Inside your project folder, create an `airun` subfolder.
9. **Start MCP servers and codemie-plugins**

   **For MacOS/Linux:**
    ```bash
    cd <absolute_path_to_your_project>
    export FILE_PATHS=/<absolute_path_to_your_project>
    export ALLOWED_DIR=/<absolute_path_to_your_project>
    codemie-plugins mcp run -s filesystem -e filesystem=ALLOWED_DIR
    ```

   **For Windows:**
    ```bash
    cd <absolute_path_to_your_project>
    set FILE_PATHS=<absolute_path_to_your_project>
    set ALLOWED_DIR=<absolute_path_to_your_project>
    codemie-plugins mcp run -s filesystem -e filesystem=ALLOWED_DIR
    ```

---

## Workflow Execution Steps

10. Go to Workflows templates
11. Locate and create the workflow: **AWS SCT Conversion finisher**
12. Go to Workflows and run.
13. Find the results in the folder created in step 7

---

## Support Scripts

For more effective and automated workflows, use the following support scripts:

### Links for scripts: 
`guide/workflows/resources/aws-sct-conversion-finisher`

### Input Preparation
- `filter_fully_converted.py`
- `split_into_batches.py`

### Compilation & Debugging
- `compile_batches.py`
- `get_compilation_errors_report.py`
- `calculate_overall_compilation_statistics.py`

---

## Directory Structure Example

```
project_root/
├── aws_sct_sql_files/
│   ├── sct_already_converted/
│   │   ├── object_1.sql
│   │   ├── object_2.sql
│   │   └── ...
│   ├── object_1.sql
│   ├── object_2.sql
│   └── ...
├── filter_fully_converted.py
├── split_into_batches.py
├── aws_sqlserver_ext-tables.csv
├── aws_sqlserver_ext-functions.csv
├── aws_sqlserver_ext-views.csv
├── compile_batches.py
├── get_compilation_errors_report.py
├── calculate_overall_compilation_statistics.py
├── batches/
│   ├── batch_1/
│   │   ├── object_1.sql
│   │   ├── object_2.sql
│   │   └── ...
│   ├── batch_2/
│   │   ├── object_51.sql
│   │   ├── object_52.sql
│   │   └── ...
│   └── ...
├── converted_db_objects/
│   ├── batch_1/
│   │   ├── object_1.sql
│   │   ├── object_1_conversion.txt
│   │   └── ... (workflow outputs)
│   └── ... 
```

---

## Best Practices

- **Batch Size:** Maintain batch sizes of ~50 files for performance and stability.
- **Concurrency:** Limit batch concurrency to 3 to prevent overloads.
- **Manual Review:** Have a database expert review complex DDLs generated.
- **Error Logging:** Review conversion notes and logs for complicated schema objects.

---

## Acronyms

- **AWS SCT:** AWS Schema Conversion Tool
- **DDL:** Data Definition Language
- **MS SQL:** Microsoft SQL Server
- **PGSQL:** PostgreSQL

---