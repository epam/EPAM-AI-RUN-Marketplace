# Overview for EPAM AI/Run™ for AWS Migration and Modernization  

EPAM AI/Run™ for AWS Migration and Modernization is a sophisticated AI assistant tool tailored specifically for developers. EPAM AI/Run™ for AWS Migration and Modernization is an innovative LLM-powered platform designed to help users to address specific challenges and find solutions for their needs. Unlike conventional large language models (LLMs) such as ChatGPT, Bard, and Copilot,EPAM AI/Run™ for AWS Migration and Modernization is engineered to support development processes more comprehensively. 
It integrates seamlessly with essential development tools including Git, Jira, Confluence, and various search engines. 
This integration empowers EPAM AI/Run™ for AWS to go beyond the capabilities of a standard chatbot, enabling it to manage Jira issues, devise appropriate implementations, and generate pull requests.
EPAM AI/Run™ for AWS leverages AI to automate coding tasks, reduce technical debt, streamline code reviews and legacy application migrations, enhance onboarding, improve information access and analysis, optimize call center operations, ensure consistent customer support, maintain data security, and analyze market sentiment, ultimately enhancing productivity and reducing costs. 
The development of such a powerful assistant necessitates extensive customization and fine-tuning. The following sections will delve into the intricate adjustments and configurations required to harness the full potential of EPAM AI/Run™ for AWS.

## Main Functionality of Codemie
EPAM AI/Run™ for AWS Migration and Modernization provides a powerful environment for developing AI-powered applications with these key capabilities:


* AI Assistant Development: Create custom assistants with specific knowledge bases and capabilities
* Workflow Automation: Design and implement workflows to automate complex processes
* Data Source Integration: Connect to various data sources to enhance AI capabilities with relevant information
* External Service Integration: Integrate with external tools and services to extend functionality

The project structure ensures proper organization, security, and collaboration while developing AI solutions. 
By separating projects, you can maintain data privacy, manage access controls, and create purpose-specific AI applications for different business needs.


## The "Project" Concept in EPAM AI/Run™ for AWS Migration and Modernization

In EPAM AI/Run™ for AWS, a project serves as a dedicated workspace or organizational unit that contains your development configurations, repository connections, and customization settings. 
It functions as the central container for all project-specific configurations.
### Project Administration

* Only administrators can create projects and assign users to them
* Users with admin role can view all projects and configure them
* Each user automatically receives a personal project associated with their email address, visible only to them

### Entity Management
When creating entities within a project, you can choose whether to make them accessible to your team:
* Create entities (assistants, workflows, data sources, integrations) privately or share them with your project team
* Use the "Shared with Project Team" toggle on the entity creation page to control visibility

### Project Isolation

 Entities are strictly isolated within their respective projects:

* You cannot mix entities from different projects
* Example: A data source created for Project X cannot be used with an assistant in Project Y

### Entity Types
Projects can contain various entity types:
* Assistants
* Workflows
* Data sources
* Integrations

### ⚠️ Warning
Be careful when sharing data source or data integration entities with your project team. 
Ensure you don't accidentally share data that shouldn't be accessible to other team members or provide your access to external service from integration functionality.

The message clearly warns users about two important aspects:
* Being cautious about sharing sensitive data
* Being careful not to expose access to external services through integration functionality

# Roles

In our system, we support two distinct roles: User and Admin. These roles can be configured through Keycloak, our identity management solution.

User Role: Standard access with basic operations and viewing capabilities within assigned projects.

Admin Role: Enhanced permissions allowing configuration changes and administrative actions within specific projects.

Configuring Project Admin Access
To assign admin privileges for specific projects to a user, follow these steps:

* Create the applications_admin attribute in Keycloak, following the same procedure as for the applications attribute 
* Create a new user with the basic "User" role
* Add the projects where the user should have regular access using the applications attribute
* Add the projects where the user should have administrative access to the applications_admin attribute


> Important Note: You only need to create the applications_admin attribute once in Keycloak. After initial creation, you can reuse this attribute for all subsequent users requiring project admin access.
