# EPAM AI/Run™ for AWS Migration and Modernization - Assistants

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This guide provides comprehensive information about working with Assistants in the EPAM AI/Run™ for AWS Migration and Modernization platform.

## Table of Contents

- [Overview](#overview)
- [Types of Assistants](#types-of-assistants)
- [Creating an Assistant](#creating-an-native-assistant)
- [Creating Bedrock Assistants](#creating-bedrock-assistants)
- [Using Assistants](#using-assistants)
- [List of Template Assistants](#list-of-template-assistants)


## Overview

Assistants in EPAM AI/Run™ for AWS Migration and Modernization are specialized AI agents designed to help with different aspects of the Software Development Life Cycle (SDLC). 
Unlike standard AI chatbots, these assistants can be equipped with specific tools, access to data sources, and specialized knowledge to perform targeted tasks.

EPAM AI/Run™ for AWS offers three main categories:

- **Project Assistants**: Personal and project-specific assistants you create or customize
- **Marketplace Assistants**: Global assistants shared by the community
- **Template Assistants**: Pre-built assistant templates for common roles and tasks

## Types of Assistants

EPAM AI/Run™ for AWS Migration and Modernization supports two main types of assistants:

1. **Native Assistants**: These are created directly within the EPAM AI/Run™ for AWS Migration and Modernization platform. They can be customized with specific tools, data sources, and configurations to suit various development tasks and workflows.

2. **AWS Bedrock Assistants**: These are created in the AWS Bedrock service and integrated with EPAM AI/Run™ for AWS Migration and Modernization. They leverage Amazon's foundation models and can be used alongside native assistants for enhanced capabilities.

## Creating an Native Assistant

1. Navigate to the **Assistants tab** in EPAM AI/Run™ for AWS Migration and Modernization
2. Click on **Create Assistant**
3. Configure your assistant:
   - Select a project from the dropdown menu
   - Choose sharing options (Shared with Project Team or Global)
   - Enter a name for your assistant
   - Provide a unique slug (human-readable identifier)
   - Add a description of the assistant's purpose
   - Enter system instructions to guide the assistant's behavior
   - Add an optional Icon URL
   - Select a Model Type 
   - Set Temperature and Top P values (optional)
   - Select Datasource Context (repositories that completed indexing)
   - Choose relevant tools

   > **Important note**: Please choose only the tools that are relevant to your needs. Selecting all available tools can negatively affect the results, slow down response times, and increase costs.

4. Click **Create** to finish

## Creating Bedrock Assistants
1. Create an AWS integration by following the instructions in the project guide located at **integration/README.md**
2. Create AWS agent in follow the official [AWS documentation](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-create.html)
3. Go Settings profile
   <img src="assets/assistant-guide/go_to_settings.png">
   <img src="assets/assistant-guide/go_to_settings_2.png">
4. Find your AWS integration from step 1
   <img src="assets/assistant-guide/find_aws_integration.png">
5. Find your AWS agent from step 2
   <img src="assets/assistant-guide/find_aws_agent.png">
6. Install agent
   <img src="assets/assistant-guide/install_agent.png">


   

## Using Assistants

1. Find the assistant you want to use in the Assistants panel
2. Click **Start Chat** next to the assistant's name
3. Type your question or request in the text field
4. To switch to a different assistant during conversation, tag it using the @ symbol


ℹ️ Pay attention to the assistant templates - they are useful for all aspects of the SDLC and can significantly accelerate your development process.

## List of Template Assistants
1. [Template] Code Reviewer
2. [Template] Epic/User story Composer
3. [Template] GitLab CI/CD Assistant
4. [Template] Release Manager Assistant
5. [Template] QA Test Case Assistant
6. QA Checklist Assistant
7. [Template] QA Test Case Assistant
8. Local Developer via Plugin Engine
9. [Template] Epic/User story Composer


Before creating an assistant using the template, please review all tools, data sources, integrations and variable. Update any components that are required for your specific needs:
 - Integrations 
 - Data source 
 - Replace if need <JIRA_PROJECT_CODE> placeholder  
 - Replace if need <CONFLUENCE_SPACE> placeholder 
 - Replace if need <CI_REPOSITORY_NAME> placeholder  
 - ....