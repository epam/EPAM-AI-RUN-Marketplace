# .NET: Migration .NET Framework v4.5.2 to .NET 8

This guide provides a step-by-step workflow for migrating a project from .NET Framework v4.5.2 to .NET 8.

---

## ⚠️ Warning

- Ensure the source code is located in the `main` branch.
- If your source code is in a different branch, during **Step 7**, update all instances of `main` with your branch name (there are two places to update).
- The Git data source should always point to your target branch.

---

## Steps to Migrate

### 1. Create Git Integration
Set up a Git integration with **read and write** access to the repository where the project source code is stored.

---

### 2. Create Git Data Source
Create a Git data source using the credentials from **Step 1**.

---

### 3. Create a File Data Source with Best Practices Instructions
Create a data source of type **File** that provides detailed instructions for the workflow on how to implement OKTA integration following best practices. The file for the data source is located at the following path: **guide/attachment/dot-net8-instructions.txt**

---

### 4. Navigate to the Workflow Template
Go to the workflow template library and locate the template named:  
`.NET: Migration .NET Framework v4.5.2 to .NET 8`.

---

### 5. Share Workflow Template with Project
Share the `.NET: Migration .NET Framework v4.5.2 to .NET 8` workflow template with your target project.

---

### 6. Customize the YAML Configuration
Update the `datasource_ids` values in the YAML configuration file as follows:
1. **For Assistants**: Add the Git data source ID created in **Step 2**.
2. **For Other Usage**: Add the Git data source and File data source ID's created in **Step 2** and **Step 3**.

---

### 7. Update Branch Name (If Using a Different Branch)
If you are working in a branch other than `main`, update all mentions of `main` in the YAML configuration to match your branch name. There are two occurrences that need updating.

---

### 8. Name the Workflow
Assign a name to the new workflow during customization.

---

### 9. Run the Workflow
Start the workflow process.

---

### 10. Wait for Completion
Wait for the workflow to finish processing.

---

### 11. Review Migration Output
Once the workflow is complete, check the following:
- Review the Pull Requests (PRs) for the changes.
- Review the newly created branch named `net-migration`.

---