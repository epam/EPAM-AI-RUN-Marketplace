# AWS SCT Conversion Finisher

## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 13.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address




1. Install Python 3.12 or higher
2. Install uvx
3. Install Node.js 22 or higher
4. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```
5. Define connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
```
 {
  "PLUGIN_KEY": "<Any value>",
  "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
 } 
   ```
6. Create plugin project integration on AI/Run™ with value from config.json files using PLUGIN_KEY, and "Alias" property should be  "demo-plugin-integration"
7. Create folder with all your folders and files
8. Create folder in folder from previous step with name  : ```airun```
9. Add ```00bootstrap.json``` files with next values in ```airun```
```
 {
  "project_base": "absolute_path_to_your_project_or_file",  
 }
```
10. Run MCP servers and codemie-plugins
    For MacOS & Linux
```bash
  cd <absolute_path_to_your_project>
  export PROJECT_BOOTSTRAP=/<absolute_path_to_your_project>/airun
  export FILE_PATHS=/<absolute_path_to_your_project>
  export ALLOWED_DIR=/<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem -e filesystem=ALLOWED_DIR
```
For Windows
```bash
  cd <absolute_path_to_your_project>
  set PROJECT_BOOTSTRAP= <absolute_path_to_your_project>\airun
  set FILE_PATHS=<absolute_path_to_your_project>
  set ALLOWED_DIR=<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem -e filesystem=ALLOWED_DIR
```
11. Go to Workflows templates
12. Find and create next workflow ```AWS SCT Conversion finisher```
13. Go to Workflows and run 
14. Result you can find in folder from step 7