# JavaMig: Migration Java 8 to Java 17

This guide provides step-by-step instructions on running the "JavaMig: Java Repository Migration/Modernization" workflow

---

## ⚠️ Warning

- Make sure the `main` branch is protected to prevent unintended changes.
- Make sure that your Project Git integration, Git data source, and workflow are created for the same project.
---

## Steps to Migrate

### 1. Create Git Integration
Set up a Project Git integration with **read and write** access to the repository where the project source code is stored.

---

### 2. Create Git Data Source
Create a Git data source using the credentials from **Step 1**.

---

### 3. Navigate to the Workflow Template
Go to the workflow template library and locate the template named:  
`JavaMig: Java Repository Migration/Modernization`.

---

### 4. Share Workflow Template with Project
Share the `JavaMig: Java Repository Migration/Modernization` workflow template with your target project.

---

### 5. Customize the YAML Configuration
Update  variable values in the YAML configuration file as follows:
1. Replace **<GIT_DATASOURCE_ID>** with the Git data source ID that was created in **Step 2**
2. Replace **{target-branch}** with the name of the branch that will be created. All results will be located in this branch
3. Replace **{source-branch}** with the name of the branch from which the process will start.
4. Replace **{source-repository}** with the name of the repository from which the process will start
---

### 6. Name the Workflow
Assign a name to the new workflow during customization.

---

### 7. Run the Workflow
Start the workflow process.

---

### 8. Wait for Completion
Wait for the workflow to finish processing.

---

### 9. Review Migration Output
Once the workflow is complete, check the newly created branch named in **Step 5**.

---