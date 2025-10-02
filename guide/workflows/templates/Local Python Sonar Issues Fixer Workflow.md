# Local Python Sonar Issues Fixer Workflow

## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 13.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address
- Sonar is configured 



# Step for run
1. Create git integration 
2. Create data source with integration from previous step
3. Copy id of data source 
4. Create Sonar integration 
5. Copy integration alias
6. Find ```Local Python Sonar Issues Fixer Workflow``` template  
7. Click on ```Create workflow``` button
8. Update/add next property:
 - assistant_id - change to value from step 3
 - integration_alias - add the property to tool Sonar section with value, for example  
   ```
   tools:
    - name: Sonar
    - integration_alias: "your-alias"
   ```
9. Create the workflow
10. Run the workflow 
11. Wait until the workflow finish 
12. Review new PR which was created by workflow 