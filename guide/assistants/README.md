# EPAM AI/Run™ for AWS - Assistants

[![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

This guide provides comprehensive information about working with Assistants in the EPAM AI/Run™ for AWS platform.

## Table of Contents

- [Overview](#overview)
- [Creating an Assistant](#creating-an-native-assistant)
- [Using Assistants](#using-assistants)
- [Managing Assistants](#managing-assistants)
- [AWS Integration](#aws-integration)
- [Best Practices](#best-practices)

## Overview

Assistants in EPAM AI/Run™ for AWS are specialized AI agents designed to help with different aspects of the Software Development Life Cycle (SDLC). Unlike standard AI chatbots, these assistants can be equipped with specific tools, access to data sources, and specialized knowledge to perform targeted tasks.

EPAM AI/Run™ for AWS offers three main categories:

- **Project Assistants**: Personal and project-specific assistants you create or customize
- **Marketplace Assistants**: Global assistants shared by the community
- **Template Assistants**: Pre-built assistant templates for common roles and tasks

## Types of Assistants

EPAM AI/Run™ for AWS supports two main types of assistants:

1. **Native Assistants**: These are created directly within the EPAM AI/Run™ for AWS platform. They can be customized with specific tools, data sources, and configurations to suit various development tasks and workflows.

2. **AWS Bedrock Assistants**: These are created in the AWS Bedrock service and integrated with EPAM AI/Run™ for AWS. They leverage Amazon's foundation models and can be used alongside native assistants for enhanced capabilities.

## Creating an Native Assistant

1. Navigate to the **Assistants tab** in EPAM AI/Run™ for AWS
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
2. Follow the official AWS documentation to [Create and configure agent - Amazon Bedrock](https://docs.aws.amazon.com/bedrock/latest/userguide/agents-create.html)
3. Install agent

## Using Assistants

1. Find the assistant you want to use in the Assistants panel
2. Click **Start Chat** next to the assistant's name
3. Type your question or request in the text field
4. To switch to a different assistant during conversation, tag it using the @ symbol



ℹ️ Pay attention to the assistant templates - they are useful for all aspects of the SDLC and can significantly accelerate your development process.