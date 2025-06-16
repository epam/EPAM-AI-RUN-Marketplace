# VM: Migration VMware to AWS Workflow

This guide provides a step-by-step process for migrating virtual machines from VMware to AWS.

---

## ⚠️ Warning

This workflow does **not require** any data source or additional integrations. Ensure that you only provide the necessary JSON file during the workflow execution.

---
## Steps for Migration

### 1. Navigate to the Workflow Template
Go to the workflow template library and locate the template named:  
`VM: Migration VMware to AWS`.

---

### 2. Share Workflow Template with Project
Share the `VM: Migration VMware to AWS` workflow template with your target project.

---

### 3. Name the Workflow
Assign a name to the new workflow during customization.

---

### 4. Run the Workflow
Start the workflow process by attaching the required **JSON file** (vm_snapshot file) for the migration.
You can find an example of the file at the following path:
`guide/attachment/vm-migration`
---

### 5. Wait for Completion
Wait for the workflow to finish processing.

---

### 6. Check Output
The output of the workflow is instruction how you can make the migration