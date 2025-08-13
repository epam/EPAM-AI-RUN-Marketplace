## EPAM AI/Run™ for AWS - Data Sources Overview

EPAM AI/Run™ for AWS leverages various data sources to provide assistants with relevant knowledge and context, enhancing their ability to deliver accurate and helpful responses. Data sources serve as the knowledge foundation for your assistants, allowing them to reference specific project information when answering questions.

### Types of Data Sources

The platform supports several types of data sources:

- **Git**: Connect to code repositories for code-aware assistance
- **Confluence**: Index Confluence spaces and pages for knowledge management
- **Jira**: Connect to Jira spaces to access project management information
- **Files**: Upload various file formats including:
    - PDF documents (technical documentation, guides)
    - Text files (.txt)
    - Spreadsheets (.csv) with configurable parsing options
    - Presentations (.pptx)
    - Structured data files (.xml, .json, .yaml)
- **Google Docs**: Index content from Google documents

### Setting Up Data Sources

1. Navigate to the **Data Sources** tab in EPAM AI/Run™ for AWS
2. Click **Create Datasource**
3. Fill in the required fields:
    - **Project**: Select your project from the dropdown
    - **Data source name**: Enter a unique name (4-25 characters, lowercase, no spaces)
    - **Description**: Provide a clear description
    - **Shared with Project Team**: Toggle on/off based on sharing preferences
    - **Data Source Type**: Select the appropriate type
    - Complete type-specific fields (repository URL, file upload, etc.)
4. Click **Add** to create the data source

> **Important note**: For Google Docs integration, you'll need to share the document with the platform's service account to enable indexing.

### Managing Data Sources

The platform provides several management features:

- **Filtering**: Filter data sources by type, project, author, or status
- **Reindexing**: Trigger manual reindexing via the actions menu:
    - **Full Reindex**: Complete refresh of all data
    - **Incremental Index**: Update with only new or changed information
- **View/Edit**: Examine or modify data source settings
- **Status Monitoring**: Track indexing progress and completion status

### Using Data Sources with Assistants

After adding and indexing data sources:

1. Create or edit an assistant
2. In the **Datasource Context** section, select the relevant data sources
3. The assistant will now be able to reference information from these sources when responding to queries

Data sources significantly expand your assistants' capabilities by providing them with specialized knowledge about your projects, documentation, and code repositories, enabling more accurate and contextual responses.
