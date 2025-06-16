# OKTA Implementation Workflow

This guide provides a step-by-step process for integrating OKTA authentication into your project.

---

## ⚠️ Warning

- Make sure the `main` branch is protected to prevent unintended changes.
- Ensure the source code is located in the `main` branch.
- If your source code is in a different branch, during **Step 6**, update all instances of `main` with your branch name (there are two places to update).
- The Git data source should always point to your target branch.

---

## Steps for OKTA Implementation

### 1. Create Git Integration
Set up a project Git integration with **read and write** access to the repository where the project source code is stored.

---

### 2. Create Git Data Source
Create a Git data source using the credentials from **Step 1**.

---

### 3. Navigate to the Workflow Template
Go to the workflow template library and locate the template named:  
`OKTA Implementation`.

---

### 4. Share Workflow Template with Project
Share the `OKTA Implementation` workflow template with your target project.

---

### 5. Customize the YAML Configuration
Update the `datasource_ids` values in the YAML configuration file with id from data source which was created in **Step 2**.

---

### 6. Update Branch Name (If Using a Different Branch)
If you are working in a branch other than `main`, update all mentions of `main` in the YAML configuration to match your branch name. There are two occurrences that need updating.

---

### 7. Name the Workflow
Assign a name to the new workflow during customization.

---

### 8. Run the Workflow
Start the workflow process.

---

### 9. Wait for Completion
Wait for the workflow to finish processing.

---

### 10. Review Implementation Output
Once the workflow is complete, check the following:
- Review the Pull Requests (PRs) for authentication-related changes.
- Review the newly created branch named `okta-integration`.

---