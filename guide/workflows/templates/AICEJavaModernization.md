# AICE: Java Repository Migration/Modernization

## Quick Setup Guide

This guide describes how to prepare your environment for migrating a legacy Java 8 repository to Java 17 with Spring Boot using the EPAM AICE tool. The process is agent-driven and results in an automated pull request with a modernized codebase.

---

## ⚠️ Warnings & Preparation

- **Make sure the main branch is protected to prevent unintended changes.**
- Ensure source code is in the main branch.  
  If your source is in a different branch, update all instances of `main` to your branch name in Step 7 and the YAML config (two places).
- The Git data source must always point to your target branch.

---

## Essential Environment Setup Steps
1. **Create AICE Code ANalysis and Code Exploration**  
   Create AICE CodeExploration and CodeAnalysis for your project repository.
2. **Create Git Integration**  
   Set up Git integration with read/write access to your project repository.
3. **Configure Git Data Source**  
   Create a Git data source using the credentials from Step 1.
4. **Create Assistants from Template**  
   Go to the assistants template library and find the "AICE: Java Migration Assistant" and "AICE: Mason Java Migration Assistant" Assistants in your project and update their datasources with AICE code analysis and code exploration.
5. **Create Workflow from Template**  
   Go to the workflow template library and find the "AICE: Java Repository Migration/Modernization" and create workflow in your project.
6. **Customize YAML Configuration**  
   Update these in the workflow YAML:
   - For Assistants: Include your Git data source IDs.
   - For Additional Usage: Add both Git and File data source IDs.
7. **Name Your Workflow**  
   Assign an appropriate name to your workflow.
8. **Run the Workflow**  
   Start the migration process via the workflow system.
9. **Wait for Completion**  
    The workflow automates all migration steps.
10. **Review Migration Results**  
    - Review Pull Requests (PRs) with the modernization changes.
    - Check the newly created migration branch.

---

## Minimum Required Tools

- Java 17 installed locally
- Maven and Spring Boot support
- Git credentials for repository access
- EPAM AICE analysis and assistants (Mason, Dev) configured

---

## Output

- Modernized Java 17 project (Spring Boot) on a new migration branch
- Automated PR for code review
- Validation report (if configured)

---

## Best Practices

- Run AICE analysis on the entire legacy codebase for accuracy.
- Use clear commit messages (e.g., `pom_xml--added-dependency-for-jpa`).
- Protect your main branch before running migrations.